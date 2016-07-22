class MapdataController < ApplicationController
  def show
    start_date =           params[:start_date] ||= 4.days.ago.to_date
    end_date =             params[:end_date] ||= 4.days.ago.to_date
    start_date =           Date.parse(start_date)
    end_date =             Date.parse(end_date)
    @activity_collection = []
    @activities_geojson =  []

    start_date.upto(end_date) do |date|
      if !current_user.storylines.find_by_story_date(date).blank?
        # get features from db if present
        moves = current_user.storylines.find_by_story_date(date).segments.where(segment_type: "move")
        moves.each do |move|
          move.activities.each do |activity|
            build_activity_feature(activity, @activity_collection)
          end
        end
      else
        # get features from moves api
        moves_response = current_user.moves.daily_storyline(date, :trackPoints => true).first
        storyline = current_user.storylines.create(
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
          puts segment["activities"]
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
    # send a pile of json to the frontend
    render json: @activities_geojson
  end

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
    }

    coordinates = []
    activity.track_points["points"].each do |point|
      coordinates.push([point["lon"], point["lat"]])
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

