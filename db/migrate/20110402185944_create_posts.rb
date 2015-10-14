class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer     :website_id
      t.references  :user           # Owner
      t.references  :post           # Parent Post ID
      t.text        :title
      t.text        :description
      t.text        :comma_separated_tags
      t.string      :address_by_user    # Address typed by user next to the "Find!" button

      # Fields from map api

      t.text        :map_data           # Data returning from the Map API
      t.string      :map_address        # Address
      t.integer     :map_lat            # With 6 decimal digit = 10cm (http://en.wikipedia.org/wiki/Decimal_degrees)
      t.integer     :map_lng            # With 6 decimal digit = 10cm
      t.string      :map_bounds         # 
      t.integer     :map_zoom           # 

      #t.string      :level_2            # Country
      #t.string      :level_3            # Region
      #t.string      :level_4            # Province
      #t.string      :level_5            # Municipality

      # Others

      t.string      :editing_comment    # Typed by a user that modify this record

      # Sorting fields

      t.integer     :count_children
      t.integer     :count_views    # Count the records in votes table, regardeless the type of vote.

      t.integer     :count_vote_1         # Former count_votes
      t.integer     :count_vote_2
      t.integer     :count_vote_3
      t.integer     :count_vote_4

      t.string      :status         # ERROR, ACTIVE, DRAFT, DELETED, HIDDEN, IN_PROGRESS, SOLVED, etc.
      t.string      :progress       # Percentage of progress in case is an idea
      t.string      :errors_list  
      t.timestamps


#      t.integer     :count_dislike

      # t.integer     :level_of_influence # From 0 (world) to 7 (street)

#      t.string       :type             # Problem,Solution,Sale,Event,Location,News,Information
#      t.string       :item_status      # ACTIVE, DRAFT, DELETED, HIDDEN, etc.

#      t.text         :history          # Typed by users, it is an overview of everything that happened

#      t.string       :responsable      # In case of problem
#      t.string       :owner
#      t.string       :organizer        # In case of event

#      t.integer      :gps_radius       # Size of influence

#      t.string       :loc_address_by_user
#      t.string       :loc_address
#      t.string       :loc_level_1
#      t.string       :loc_level_2
#      t.string       :loc_level_3
#      t.string       :loc_country

#      t.datetime     :datetime_start
#      t.datetime     :datetime_stop    # Deadline in case of SOLUTION in PROGRESS

#      t.integer      :people_effected  # Effected by the problem, attending an event, etc.

#      t.integer      :cost             # In cents (With 2 decimal digit)
#      t.string       :cost_currency    # USD, EUR, JPY, etc.
#      t.string       :cost_units       # per month, per meter, etc.

#      t.string       :solution_status  # IN_PROGRESS, SUCCEDED (problem solved), FAILED
#      t.integer      :progress         # Percentage - In case a SOLUTION is in progress

#      t.integer      :owner_user_id    # User that own the thread of items and has some privilege on it

#      t.integer      :parent_1_item_id # In case of Event, it could be the Location
#      t.integer      :parent_2_item_id #

#      t.integer      :votes_like       # This is just to speed up performance
#      t.integer      :votes_dislike    #

#      t.boolean      :last_editing     # Yes|No (Only items with Yes will be active and displayed on the map.)
                                        # There is the risk that if the item "last" is gone, all the thread will
                                        # disappear.
#      t.integer      :first_item_id    # Original item in case this is an editing. All the items that share
                                        # tha same iniziator are used to build the history
    end
  end

  def self.down
    drop_table :posts
  end
end

