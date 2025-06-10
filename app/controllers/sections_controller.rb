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
end
