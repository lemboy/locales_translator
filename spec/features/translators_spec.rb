require 'rails_helper'

describe "translator" do
  let(:src_file_path) { File.join(Rails.root,           'spec/fixtures/yml/source_file.yml') }
  let(:bad_file_path) { File.join(Rails.root,           'spec/fixtures/yml/incorrect_file.yml') }
  let(:trgt_custom_file_path) { File.join(Rails.root,   'spec/fixtures/yml/download/target_file.yml') }
  let(:trgt_default_file_path) { File.join(Rails.root,  'spec/fixtures/yml/download/fr.yml') }
  let(:draft_default_file_path) { File.join(Rails.root, 'spec/fixtures/yml/download/en-fr-draft.json') }
  let(:draft_custom_file_path) { File.join(Rails.root,  'spec/fixtures/yml/download/target-draft.json') }
  let(:original_word) { 'Сrucian' }
  let(:translated_word) { 'Carassin' }
  let(:another_translated_word) { 'Champignon' }
  let(:draft_word) { 'Draft' }

  before { visit root_path }

  describe "root path" do
    it "should have upload button" do
      expect(page).to have_css '#src-file'
    end
  end

  describe "after upload" do 
    context "incorrect file" do
      before { attach_file 'src_file', bad_file_path }
      it "should no have fields", js: true do
        expect(page).not_to have_css '#src-file-name'
      end
      it "should have error message", js: true do
        expect(find('.alert-danger'))
      end
    end

    context "correct file" do
      before { attach_file 'src_file', src_file_path }
      it "should have correct fields value", js: true do
        expect(find('.alert-info'))
        expect(find('input#src-lang').value).to have_content 'English'
        expect(find('select#trgt-lang').value).to have_content 'af'
        expect(find('textarea#src-array-3')).to have_content original_word
      end
    end
  end      

  shared_examples "save target file shared" do
    before { attach_file 'src_file', src_file_path }
    before { find('textarea#trgt-array-3').set translated_word }
    before { find('select#trgt-lang').select 'French' }
    before { find('input#trgt-file-name').set trgt_file_name }
    before { find_button('Save file').click }            
    before { attach_file 'src_file', trgt_file_path }
    it "should have translated word", js: true do
      expect(find('input#src-lang').value).to have_content 'French'
      expect(find('textarea#src-array-3')).to have_content translated_word
    end
  end

  describe "after save file" do 
    context "with default name" do
      it_behaves_like "save target file shared" do
        let(:trgt_file_name) { '' }
        let(:trgt_file_path) { trgt_default_file_path }
      end
    end
    context "with custom name" do
      it_behaves_like "save target file shared" do
        let(:trgt_file_name) { 'target_file' }
        let(:trgt_file_path) { trgt_custom_file_path }
      end
    end
  end

  shared_examples "save draft file shared" do
    before { attach_file 'src_file', src_file_path }
    before { find('textarea#trgt-array-3').set draft_word }
    before { find('select#trgt-lang').select 'French' }
    before { find('input#trgt-file-name').set trgt_file_name }
    before { find_button('Save draft').click }            
    before { attach_file 'draft_file', trgt_file_path }
    it "should have translated word", js: true do
      expect(find('input#src-lang').value).to have_content 'English'
      expect(find('select#trgt-lang').value).to have_content 'fr'
      expect(find('textarea#trgt-array-3')).to have_content draft_word
    end
  end

  describe "after save draft file" do 
    context "with default name" do
      it_behaves_like "save draft file shared" do
        let(:trgt_file_name) { '' }
        let(:trgt_file_path) { draft_default_file_path }
      end
    end
    context "with custom name" do
      it_behaves_like "save draft file shared" do
        let(:trgt_file_name) { 'target' }
        let(:trgt_file_path) { draft_custom_file_path }
      end
    end
  end

  describe "with machine translation" do
    before { attach_file 'src_file', src_file_path }
    context "when select proper target language" do
      before { find('select#trgt-lang').select 'French' }
      it "should be enabled", js: true do
        expect(find("span#auto-transl-all[data-disabled='false']"))
        expect(find("span#auto-transl-3[data-disabled='false']"))
      end
      context "can translate key" do
        before { find("span#auto-transl-3").click }
        it "properly", js: true do
          expect(find('.alert-info'))
          expect(page).to have_field "trgt-array-3", with: translated_word 
        end
      end
      context "can translate all keys" do
        before { find("span#auto-transl-all").click }
        it "properly", js: true do
          expect(find('.alert-info'))
          expect(page).to have_field "trgt-array-3", with: translated_word
          expect(page).to have_field "trgt-array-8", with: another_translated_word
        end
      end
    end

    context "when select not proper target language" do
      before { find('select#trgt-lang').select 'Pirate' }
      it "should be disabled", js: true do
        expect(find("span#auto-transl-all[data-disabled='true']"))
        expect(find("span#auto-transl-3[data-disabled='true']"))
      end
    end
  end

end
