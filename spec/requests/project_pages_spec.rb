require 'spec_helper'

describe "Project pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do
    
    describe "for signed-in users" do
      
      before do 
        sign_in(user)
        visit projects_path
      end
      
      it { should have_content('Projects') }
      it { should have_title(full_title('Project List')) }
      it { should_not have_title('| Home') }
      
      describe "with no projects in the system" do
        
        it "should have an information message" do
          expect(page).to have_content('No Projects found')
        end
      end
      
      describe "with projects in the system" do
        before do
          FactoryGirl.create(:project, code: 'P2000')
          FactoryGirl.create(:project, code: 'P3000')
          visit projects_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Project Title')
          expect(page).to have_selector('table tr th', text: 'Project Code')
        end
                   
        it "should list each project" do
          Project.paginate(page: 1).each do |project|
            expect(page).to have_selector('table tr td', text: project.title)
            expect(page).to have_selector('table tr td', text: project.code)
          end
        end
        
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit projects_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "Show page" do
    
    let!(:project) { FactoryGirl.create(:project,  code: 'P2000', 
                                                    description: 'A description of the project'
                                                    ) }
        
    describe "for signed-in users" do
      
      before { sign_in(user) }
      before { visit project_path(project) }
      
      let!(:page_heading) {"Project " + project.code}
      
      it { should have_selector('h2', :text => page_heading) }
      it { should have_title(full_title('Project View')) }
      it { should_not have_title('| Home') }  
      
      describe "should show correct associations" do
        before { FactoryGirl.create(:sample_set, owner: user, project_id: project.id, num_samples: 20 ) }
        
        describe "when showing the samples belonging to this project" do
          let!(:first_sample_id) { project.samples.first.id }
          let!(:last_sample_id) { project.samples.last.id }
          before { visit project_path(project) }
          it { should have_content('Samples associated with this Project') }
          it { should have_selector('table tr th', text: 'Sample ID') } 
          it { should have_selector('table tr td', text: first_sample_id) } 
          it { should have_selector('table tr td', text: last_sample_id) } 
        end
        
        describe "when showing the sample sets belonging to this project" do
          let!(:first_sample_set_id) { project.sample_sets.first.id }
          let!(:last_sample_set_id) { project.sample_sets.last.id }
          before { visit project_path(project) }
          it { should have_content('Sample Sets associated with this Project') }
          it { should have_selector('table tr th', text: 'Sample Set ID') } 
          it { should have_selector('table tr td', text: first_sample_set_id) } 
          it { should have_selector('table tr td', text: last_sample_set_id) } 
        end
      
      end
    
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit project_path(project) }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
end