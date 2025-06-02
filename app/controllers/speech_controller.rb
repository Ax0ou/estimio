require "openai"

class SpeechController < ApplicationController
  protect_from_forgery except: :to_text

  def to_text
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
end
