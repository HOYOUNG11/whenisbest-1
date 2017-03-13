module AlgorithmHelper
    require 'set'
    require 'months_conversion_helper.rb'
  
    def in_future(event)
      if event.month.kind_of?(String)
        month = get_month(event.month)
      else
        month = event.month
      end
      
      event_time = Time.new(event.year.to_i,month,event.day.to_i)
      
      return event_time > Time.current
    end

    def all_events(user_id,future=false)
      event_set = Set.new
      
      events = CalendarEvent.where(host: user_id).find_each.to_set
      events.each do |event|
        if (in_future(event) and future) or not future
          event_set.add(event)
        end
      end

      user = User.find(user_id)

      group_event_set = Set.new
      user.group_ids.each do |group_id| 
        group_events = CalendarEvent.where(:group => group_id).find_each 
        
        group_events.each do |event|
          if (in_future(event) and future) or not future
            group_event_set.add(event)
          end
        end

      end 

      event_set.merge(group_event_set)

      return event_set
    end
  
    def get_group_events(group)
    
      event_set = Set.new
      
      
      group.group_members.each do |user|
        user_events = []
        if user.kind_of?(User)
          user_events = all_events(user.id,future=true)
        else
          user_events = all_events(user,future=true)
        end
        
        event_set.merge(user_events)
      
      end
      
      return event_set
    end
end