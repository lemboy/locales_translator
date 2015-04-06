class TranslatorsController < ApplicationController
  before_action :auto_translate_prepare, only: [:index]

  def index
  end

  def upload_file
    src_file = params[:src_file].tempfile
    @src_file_name = params[:src_file].original_filename
    ajax_status = 200

    begin
      @src_content = YAML.load src_file
    rescue Psych::SyntaxError => se
      src_file.close
      src_file.unlink
      flash[:danger] = "Invalid syntax of YML file: #{@src_file_name}"
      ajax_status = 404
    end

    if flash[:danger].nil? && @src_content.class != Hash
      flash[:danger] = "Invalid YML file: #{@src_file_name}" 
      ajax_status = 404
    end
    
    respond_to do |format|
      format.js { render status: ajax_status }
      format.html { redirect_to root_path }
    end
  end

  def upload_draft
    src_file = params[:draft_file].tempfile
    @src_file_name = params[:draft_file].original_filename
    ajax_status = 200

    begin
      json_content = JSON.load File.new(src_file)
      @src_content = json_content['source']
      @trgt_content = json_content['target']
    rescue JSON::ParserError => se
      src_file.close
      src_file.unlink
      flash[:danger] = "Invalid syntax of JSON file: #{@src_file_name}"
      ajax_status = 404
    end

    respond_to do |format|
      format.js { render status: ajax_status }
      format.html { redirect_to root_path }
    end
  end

  def process_file
    respond_to do |format| 
      format.html do 
        if params[:commit] == 'Save file'
          trgt_lang_code = params[:trgt_lang]
          trgt_hash = { trgt_lang_code => params[:trgt_hash].to_hash.values[0] }
          trgt_file_name = ( params[:trgt_file_name].presence ? params[:trgt_file_name].gsub(/\.yml\Z/, '') : trgt_lang_code ) + ".yml"
          trgt_data = trgt_hash.to_yaml(options = {:line_width => -1})
          send_data trgt_data, :filename => trgt_file_name 
        else
          src_lang_code = params[:src_lang_code]
          trgt_lang_code = params[:trgt_lang]
          src_hash = { src_lang_code => params[:src_hash].to_hash.values[0] }
          trgt_hash = { trgt_lang_code => params[:trgt_hash].to_hash.values[0] }
          trgt_file_name = ( params[:trgt_file_name].presence ? params[:trgt_file_name].gsub(/\.json\Z/, '') : "#{src_lang_code}-#{trgt_lang_code}" ) + "-draft.json"
          trgt_data = { 'source' => src_hash, 'target' => trgt_hash }.to_json
          send_data trgt_data, :filename => trgt_file_name 
        end
      end
      format.js do 
        src_hash = params[:src_array]
        src_text = src_hash.inject("") { |h, (k, v)| "#{h}[#{v}]" }
        transl_dir = "#{params[:src_lang_code]}-#{params[:trgt_lang]}"

        code, trgt_text = Translator.translate CGI.escape(src_text), transl_dir

        if code == "200"  
          trgt_arr = trgt_text.gsub(/^\[|\]$/, '').split("][")
          @trgt_hash = src_hash
          @trgt_hash.each_with_index do |(k,v), i| 
            @trgt_hash[k]=trgt_arr[i]
          end
        else
          @trgt_hash = nil
          flash[:danger] = "Translate error - #{trgt_text}"
        end
      end
    end
  end

  def ajax_download
    send_data params[:data], :filename => params[:file]
  end

  def translate
    @tag_for_replace = params[:tag_id]
    transl_dir = params[:dir]
    src_text = params[:text]

    code, trgt_text = Translator.translate CGI.escape(src_text), transl_dir

    if code == "200"  
      @value_for_replace = trgt_text
    else
      @value_for_replace = ""
      flash[:danger] = "Translate error - #{trgt_text}"
    end
    
    respond_to do |format|
      format.js
      format.html { redirect_to root_path }
    end
  end

private
  
  def auto_translate_prepare
    Translator.set_autotranslate_dirs
  end

end
