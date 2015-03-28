class TranslatorsController < ApplicationController
  before_action :auto_translate_prepare, only: [:index]

  def index
  end

  def upload_file
    src_file = params[:src_file].tempfile
    @src_file_name = params[:src_file].original_filename

    begin
      @src_content = YAML.load src_file
    rescue Psych::SyntaxError => se
      src_file.close
      src_file.unlink
      flash[:error] = "Invalid syntax of YML file: #{@src_file_name}"
    end

    flash[:error] = "Invalid YML file: #{@src_file_name}" unless !flash[:error].nil? || @src_content.class == Hash

    respond_to do |format|
      format.js
      format.html { redirect_to root_path }
    end
  end

  def process_file
    respond_to do |format| 
      format.html do 
        trgt_lang_code = params[:trgt_lang]
        trgt_hash = { trgt_lang_code => params[:trgt_hash].to_hash.values[0] }
        trgt_file_name = ( params[:trgt_file_name].presence ? params[:trgt_file_name] : trgt_lang_code ) + ".yml"
        trgt_data = trgt_hash.to_yaml(options = {:line_width => -1})
        send_data trgt_data, :filename => trgt_file_name 
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
          flash[:error] = "Translate error - #{trgt_text}"
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
      flash[:error] = "Translate error - #{trgt_text}"
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
