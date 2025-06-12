# app/controllers/ai_controller.rb
class AiController < ApplicationController
  before_action :authenticate_user!

  # POST /ai/transcribe
  def transcribe
    begin
      audio_file = params[:audio]

      if audio_file.blank?
        render json: { error: "Aucun fichier audio fourni" }, status: :bad_request
        return
      end

      # Appel à votre service de transcription (OpenAI Whisper, Google Speech-to-Text, etc.)
      transcript = transcribe_audio_file(audio_file)

      if transcript.present?
        render json: {
          success: true,
          transcript: transcript,
          message: "Transcription réussie"
        }
      else
        render json: {
          success: false,
          error: "Aucun texte détecté dans l'audio"
        }, status: :unprocessable_entity
      end

    rescue => e
      Rails.logger.error "Erreur de transcription: #{e.message}"
      render json: {
        success: false,
        error: "Erreur lors de la transcription: #{e.message}"
      }, status: :internal_server_error
    end
  end

  # POST /ai/analyze_text
  def analyze_text
    begin
      text = params[:text]
      context = params[:context] || {}

      if text.blank?
        render json: { error: "Aucun texte à analyser" }, status: :bad_request
        return
      end

      # Appel à votre service d'analyse IA
      analysis_result = analyze_text_with_ai(text, context)

      render json: {
        success: true,
        analysis: analysis_result,
        message: "Analyse terminée avec succès"
      }

    rescue => e
      Rails.logger.error "Erreur d'analyse IA: #{e.message}"
      render json: {
        success: false,
        error: "Erreur lors de l'analyse: #{e.message}"
      }, status: :internal_server_error
    end
  end

  private

  def transcribe_audio_file(audio_file)
    # Exemple d'implémentation avec OpenAI Whisper
    # Adaptez selon votre service de transcription

    # Pour un vrai service, vous pourriez faire quelque chose comme :
    # OpenAI::Client.new.audio.transcriptions(
    #   parameters: {
    #     model: "whisper-1",
    #     file: audio_file
    #   }
    # )

    # Pour la démo, on simule une transcription
    sample_transcripts = [
      "Pose de carrelage dans la salle de bain, démontage de l'ancien revêtement.",
      "Peinture des murs, deux couches de blanc, préparation du support incluse.",
      "Installation électrique, pose de trois prises et deux interrupteurs.",
      "Plomberie, changement du robinet et réparation des joints."
    ]

    sample_transcripts.sample
  end

  def analyze_text_with_ai(text, context = {})
    # Exemple d'implémentation avec votre service IA
    # Adaptez selon votre implémentation (OpenAI GPT, service custom, etc.)

    # Simulation d'une analyse IA
    {
      line_items: generate_line_items_from_text(text),
      notes: "Analyse basée sur '#{text[0..50]}...'. Vérifiez les quantités et prix selon votre marché local.",
      confidence: 0.85,
      suggestions: [
        "Considérez d'ajouter une marge pour les imprévus",
        "Vérifiez la disponibilité des matériaux"
      ]
    }
  end

  def generate_line_items_from_text(text)
    # Logique pour extraire des line items du texte
    # Ici c'est une simulation, vous pourriez utiliser du NLP plus sophistiqué

    items = []

    # Détection de mots-clés et génération d'items correspondants
    if text.downcase.include?("carrelage")
      items << {
        description: "Pose de carrelage avec fourniture",
        quantity: 10,
        unit: "m²",
        price_per_unit: 45.0,
        total: 450.0
      }
      items << {
        description: "Démontage ancien revêtement",
        quantity: 2,
        unit: "h",
        price_per_unit: 35.0,
        total: 70.0
      }
    end

    if text.downcase.include?("peinture")
      items << {
        description: "Peinture murs et plafonds",
        quantity: 15,
        unit: "m²",
        price_per_unit: 12.0,
        total: 180.0
      }
      items << {
        description: "Préparation des supports",
        quantity: 3,
        unit: "h",
        price_per_unit: 30.0,
        total: 90.0
      }
    end

    if text.downcase.include?("électric")
      items << {
        description: "Installation électrique",
        quantity: 1,
        unit: "forfait",
        price_per_unit: 250.0,
        total: 250.0
      }
    end

    if text.downcase.include?("plomberie")
      items << {
        description: "Travaux de plomberie",
        quantity: 1,
        unit: "forfait",
        price_per_unit: 180.0,
        total: 180.0
      }
    end

    # Si aucun mot-clé reconnu, on génère un item générique
    if items.empty?
      items << {
        description: "Travaux selon description",
        quantity: 1,
        unit: "forfait",
        price_per_unit: 100.0,
        total: 100.0
      }
    end

    items
  end
end
