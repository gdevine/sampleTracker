module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "HIE Sample Tracker"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  
  def full_heading(first_name, surname)
    if first_name.nil? && surname.nil?
      'Home Page'
    else
      "Home Page for"+" " + first_name + " " + surname
    end
  end
  
  def show_minibar?(current_path)
    if current_path == root_path && signed_in? 
      return true
    elsif ![root_path, about_path, contact_path, help_path, register_path, signin_path].include? current_path  
      return true
    else
      return false
    end     
  end
  
end
