class User < ActiveRecord::Base
  has_many :storylines

  def self.find_or_create_from_auth_hash(auth_hash)
    case auth_hash["provider"]
    when 'moves'
      uid = auth_hash["uid"].to_s
      credentials = MovesOauthCredentials.find_or_create_by(uid: uid)
      credentials.attributes = {
        token: auth_hash["credentials"]["token"],
        refresh_token: auth_hash["credentials"]["refresh_token"],
        expires_at: Time.at(auth_hash["credentials"]["expires_at"]),
      }
      credentials.user ||= User.create
      credentials.save!
    else
      raise "unknown provider!"
    end

    credentials.user
  end

  has_many :oauth_credentials, class_name: OauthCredentials

  def moves
    @moves ||= Moves::Client.new(oauth_credentials.first.token)
  end

  def storyline_json_for_dates(start_date, end_date, places)
    @activity_collection = []
    @activities_geojson = []
    start_date.upto(end_date) do |date|
      if !self.storylines.find_by_story_date(date).blank?
        # get features from db if present
        if (places == true)
          moves = self.storylines.find_by_story_date(date).segments.where(segment_type: "move")
          moves.each do |move|
            move.activities.each do |activity|
              build_activity_feature(activity, @activity_collection)
            end
          end
        end
        if (places == false)
          moves = self.storylines.find_by_story_date(date).segments.where(segment_type: "move")
          moves.each do |move|
            move.activities.each do |activity|
              build_activity_feature(activity, @activity_collection)
            end
          end
        end
      else
        # get features from moves api
        moves_response = self.moves.daily_storyline(date, :trackPoints => true).first
        storyline = self.storylines.create(
          story_date:    moves_response["date"],
          last_update:   moves_response["lastUpdate"],
          calories_idle: moves_response["caloriesIdle"]
          )
         moves_response["segments"].each do |segment|
          seg = storyline.segments.create(
            start_time:   segment["startTime"],
            end_time:     segment["endTime"],
            last_update:  segment["lastUpdate"],
            storyline_id: storyline.id,
            segment_type: segment["type"],
            )
          if (segment["place"])
            seg_place = Place.find_or_create_by(moves_id: segment["place"]["id"]) do |place|
              place.name =                    segment["place"]["name"]
              place.place_type =              segment["place"]["type"]
              place.facebook_place_id =       segment["place"]["facebookPlaceId"]
              place.foursquare_id =           segment["place"]["foursquareId"]
              place.foursquare_category_ids = segment["place"]["foursquareCategoryIds"]
              place.latitude =                segment["place"]["location"]["lat"]
              place.longitude =               segment["place"]["location"]["lon"]
            end
            seg.place_id = seg_place.id
            seg.save
          end
          if (segment["activities"])
            segment["activities"].each do |activity|
              act = seg.activities.create(
                start_time:     activity["startTime"],
                end_time:       activity["endTime"],
                activity_type:  activity["activity"],
                activity_group: activity["group"],
                duration:       activity["duration"],
                distance:       activity["distance"],
                calories:       activity["calories"],
                steps:          activity["steps"],
                manual:         activity["manual"]
                )
              if (activity["trackPoints"] != [])
                act.track_points = {points: activity["trackPoints"]}
                act.save
                act.reload
                build_activity_feature(act, @activity_collection)
              end
            end
          end
        end
      end
    end
    @activity_collection.group_by{|i| i[:properties][:type]}.each do |activity_type|
      @activities_geojson << {
        type: "FeatureCollection",
        features: activity_type.last,
        properties: {
          type: activity_type.first,
          group: activity_type.last.first[:properties][:group],
          color: activity_type.last.first[:properties][:color]
        }
      }
    end
    @activities_geojson
  end

  private

  def build_activity_feature(activity, activity_collection)
    colors = {
      kayaking: "#1390d4",
      rollerblading: "#e0bb00",
      running: "#f660f4",
      cycling: "#00cdec",
      walking: "#00d55a",
      transport: "#848484",
      train: "#848484",
      airplane: "#848484",
      car: "#848484",
      skateboarding: "#ff8c3b",
      bus: "#848484",
      ferry: "#848484",
      scooter: "#848484"
    }

    coordinates = []
    # you wouldn't think this was necessary...
    unless activity.track_points == nil
      activity.track_points["points"].each do |point|
        coordinates.push([point["lon"], point["lat"]])
      end
    end
    activity_collection << {
      type: "Feature",
      properties: {
        type:  activity.activity_type,
        group: activity.activity_group,
        startTime: activity.start_time,
        color: colors[activity.activity_type.to_sym]
      },
      geometry: {
        type: "LineString",
        coordinates: coordinates
      }
    }
  end
end

