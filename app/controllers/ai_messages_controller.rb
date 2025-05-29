class AiMessagesController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
    @ai_message = AiMessage.new
  end

  def create
    @quote = Quote.find(params[:quote_id])
    @ai_message = @quote.ai_messages.build(ai_message_params)
    @ai_message.prompt = "#{system_prompt}\n\nUser input: #{@ai_message.description}"

    if @ai_message.save
      # Appel de la gem RubyLLM avec le prompt utilisateur
      @chat = RubyLLM.chat
      @ai_message.update(content: @chat.with_instructions(system_prompt).ask(@ai_message.description).content)
      # Stocker la réponse dans le modèle
      redirect_to quote_path(@quote)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def ai_message_params
    params.require(:ai_message).permit(:description)
  end

  def system_prompt
    "Vous êtes un entrepreneur en bâtiment chargé de créer un devis professionnel pour un projet de rénovation en France.

    À partir des éléments fournis par le client (photos et/ou description vocale), générez un devis complet et réaliste en HTML clair.

    Le rendu doit respecter la structure et la lisibilité d’un devis professionnel du bâtiment, en incluant les sections suivantes :

    ---

    1. En-tête

    - Titre du projet (en gras, par exemple **Projet : Rénovation de salle de bain**)
    - Date d’émission et date de validité
    - Numéro de devis (format 'DYYYY-XXX')

    ---

    2. Détail des prestations (par ligne)

    Pour chaque tâche :

    - Titre de la tâche (en gras noir) et montant total de la tâche, en euros (€), hors taxes, et total des sous éléments en dessous
    - En dessous, séparé par une fine ligne noire :
      - Main d’œuvre : type de professionnel, nombre d’heures estimées, tarif horaire HT, sous-total
      - Matériaux : désignation, quantité, prix unitaire HT, sous-total
      - Tous les montants doivent être affichés en euros (€), hors taxes, avec des estimations réalistes

    Utiliser une mise en page de type devis (simple, sans arrière-plan, sans bordure) en plaçant les montants à droite évidemment.

    ---

    3. Tableau récapitulatif

    En bas du devis, insérer un tableau de synthèse indiquant :

    - Total HT
    - TVA (20 %)
    - Total TTC (HT + TVA)

    Les totaux doivent être clairs, alignés à droite, avec des valeurs en gras.

    ---

    4. Estimation du temps

    Indiquer la durée totale estimée (en jours), en supposant 8 heures de travail par jour.

    ---

    5. Conditions de paiement

    Ajouter une section avec :

    - Acompte de 20 % à la signature (calculé automatiquement)
    - Solde à la livraison
    - Paiement par virement bancaire

    ---

    Exigences finales :

    - Retourner uniquement du HTML propre et professionnel
    - Ne pas inclure d’explication, de commentaires ou de balises Markdown
    - Ne pas inclure de ligne grise sur la gauche
    - La mise en page doit être facilement imprimable sur une feuille A4"
  end
end
