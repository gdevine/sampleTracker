require 'spec_helper'

describe "Analysis pages:" do

  subject { page }
  
  let(:user) { FactoryGirl.create(:user) }
  
  describe "Index page" do
    
    describe "for signed-in users" do
      
      before do 
        sign_in(user)
        visit analyses_path
      end
      
      it { should have_content('Analysis Types') }
      it { should have_title(full_title('Analysis Type List')) }
      it { should_not have_title('| Home') }
      
      describe "with no analysis types in the system" do
        
        it "should have an information message" do
          expect(page).to have_content('No Analysis types found')
        end
      end
      
      describe "with analysis types in the system" do
        before do
          FactoryGirl.create(:analysis, code: 'P2000')
          FactoryGirl.create(:analysis, code: 'P3000')
          visit analyses_path
        end
                
        it "should have correct table heading" do
          expect(page).to have_selector('table tr th', text: 'Title')
          expect(page).to have_selector('table tr th', text: 'Code')
        end
                   
        it "should list each analysis type" do
          Analysis.paginate(page: 1).each do |analysis|
            expect(page).to have_selector('table tr td', text: analysis.title)
            expect(page).to have_selector('table tr td', text: analysis.code)
          end
        end
        
      end

    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit analyses_path }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
  describe "Show page" do
    
    let!(:analysis) { FactoryGirl.create(:analysis,  code: 'An2000', 
                                                    description: 'A description of this analysis type'
                                                    ) }
        
    describe "for signed-in users" do
      
      before { sign_in(user) }
      before { visit analysis_path(analysis) }
      
      let!(:page_heading) {"Analysis Type " + analysis.code}
      
      it { should have_selector('h2', :text => page_heading) }
      it { should have_title(full_title('Analysis Type View')) }
      it { should_not have_title('| Home') }  
    
    end
    
    describe "for non signed-in users" do
      describe "should be redirected back to signin" do
        before { visit analysis_path(analysis) }
        it { should have_title('Sign in') }
      end
    end
    
  end
  
  
end