require 'spec_helper'
describe Post do
  it "is created with one marker on Japan" do
    I18n.locale = :en
    @attr = {:title => "Scandicci", :description => "Nice village in Tuscany"}
    a = Post.new(@attr)
    a.prepare_for_editing
    a.map_data = "lat:35658063; lng:139702484; b:35657686 139702041 35658251 139703393; z:19; c:Japan(24045999 122933785 45556865 148895291); 3:Tokyo(35501190 138942758 35898644 139919853); 4:Shibuya(35641564 139661354 35692141 139723895); 5:Shibuya(35653471 139701091 35664155 139713965); p:150-0031(35653122 139694966 35661789 139705178); a:Tamagawa Dori, 150-0002, Japan; v: 1.0"
    a.save!
    @id = a.id
  end
end
