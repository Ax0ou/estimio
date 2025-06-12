class SectionsController < ApplicationController
  def add_line_items_with_llm
    # binding.pry
    @section = Section.find(params[:id])
    llm_data = LlmService.new(transcript: params[:transcript][:text]).call
    CreateLineItemsFromLlmData.new(llm_data, section: @section).call
    # redirect_to edit_quote_path(@section.quote), notice: "Ligne(s) ajoutée(s) avec succès."
  end

  def transcribe_audio
    audio = params[:audio]
    return render json: { error: "Aucun fichier audio" }, status: :bad_request unless audio

    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    response = client.audio.transcribe(
      parameters: {
        model: "whisper-1",
        file: audio.tempfile,
        filename: audio.original_filename,
        response_format: "json"
      }
    )
    render json: { text: response["text"] }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    @section = Section.find(params[:id])
    if @section.destroy
      respond_to do |format|
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # POST /sections/:id/analyze_with_ai
  def analyze_with_ai
    @section = Section.find(params[:id])
    description = params[:description]
    context = params[:context] || {}
    
    if description.blank?
      render json: { success: false, error: "Description requise" }, status: :bad_request
      return
    end

    begin
      # Appel au service d'analyse IA
      analysis_result = analyze_description_with_ai(description, @section, context)
      
      if analysis_result[:success]
        # Créer les line items automatiquement
        created_items = create_line_items_from_analysis(analysis_result[:line_items], @section)
        
        render json: {
          success: true,
          line_items: created_items,
          notes: analysis_result[:notes],
          message: "#{created_items.count} éléments ajoutés avec succès"
        }
      else
        render json: { 
          success: false, 
          error: analysis_result[:error] 
        }, status: :unprocessable_entity
      end
      
    rescue => e
      Rails.logger.error "Erreur analyse IA section #{@section.id}: #{e.message}"
      render json: { 
        success: false, 
        error: "Erreur lors de l'analyse: #{e.message}" 
      }, status: :internal_server_error
    end
  end

  # GET /sections/:id/totals
  def totals
    @section = Section.find(params[:id])
    
    render json: {
      section_id: @section.id,
      total_ht: @section.total_ht,
      total_ttc: @section.total_ttc,
      line_items_count: @section.line_items.count
    }
  end

  private

  def analyze_description_with_ai(description, section, context = {})
    # Utiliser votre service d'IA existant ou en créer un nouveau
    # Ici on simule l'appel pour la démo
    begin
      ai_service = AiController.new
      result = ai_service.send(:analyze_text_with_ai, description, context.merge(section_id: section.id))
      
      {
        success: true,
        line_items: result[:line_items],
        notes: result[:notes],
        confidence: result[:confidence]
      }
    rescue => e
      {
        success: false,
        error: "Erreur d'analyse IA: #{e.message}"
      }
    end
  end

  def create_line_items_from_analysis(line_items_data, section)
    created_items = []
    
    line_items_data.each do |item_data|
      line_item = section.line_items.create!(
        description: item_data[:description],
        quantity: item_data[:quantity],
        unit: item_data[:unit],
        price_per_unit: item_data[:price_per_unit],
        price: item_data[:total]
      )
      created_items << line_item if line_item.persisted?
    end
    
    created_items
  end
end
