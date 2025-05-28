class TranscriptionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    # 1. Récupération des données du formulaire
    base64_audio = params[:audio]
    description = params[:description]

    if base64_audio.blank?
      render json: { error: "Fichier audio manquant" }, status: 400 and return
    end

    # 2. Décode le fichier base64 en fichier webm temporaire
    decoded_audio = Base64.decode64(base64_audio)
    file = Tempfile.new(['recording', '.webm'])
    file.binmode
    file.write(decoded_audio)
    file.rewind

    # 3. Appel de l’API OpenAI Whisper
    client = OpenAI::Client.new(access_token: ENV["OPENAI_API_KEY"])
    response = client.audio.transcribe(
      parameters: {
        model: "whisper-1",
        file: file,
        response_format: "text"
      }
    )

    transcription = response["text"]

    # 4. Fusionne la transcription et la description
    final_text = "#{description}\n\nNote vocale transcrite : #{transcription}"

    # 5. Pour l'instant, retourne ce contenu (plus tard on générera le devis)
    render json: { transcription: final_text }, status: 200
  ensure
    file&.close
    file&.unlink
  end
end
