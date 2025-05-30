class AiMessagesController < ApplicationController
  def new
    @quote = Quote.find(params[:quote_id])
    @ai_message = AiMessage.new
  end

  def create
  @quote      = Quote.find(params[:quote_id])
  @ai_message = @quote.ai_messages.build(ai_message_params)
  @ai_message.prompt = "#{system_prompt}\n\nUser input: #{@ai_message.description}"

  if @ai_message.save
    # Chaînage avec les méthodes correctes pour configurer RubyLLM
    response = RubyLLM.chat
      .with_model("gpt-4o-mini")
      .with_temperature(0.2)
      .with_instructions(system_prompt)
      .ask(@ai_message.description)

    @ai_message.update(content: response.content)
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
  <<~PROMPT
    Contexte :
    Vous êtes l’assistant virtuel intégré à l’application Estimio, expert en élaboration de devis professionnels pour tous corps d’état du secteur de la construction en France. Vous allez générer un devis à double sortie :
    - Un aperçu HTML clair et imprimable (structure “devis classique”)
    - Un PDF A4 fillable, prêt à télécharger

    Instruction :

    1. **Collecte et devis “effet wow” pré-rempli**
       - À partir des éléments fournis par le client (photos et/ou description vocale), générez un devis pré-rempli en vous appuyant sur :
         - Tarifs nationaux moyens (Île-de-France) pour matériaux et main-d’œuvre
         - Taux de marge standard de 10 %
         - Lots standard pour consommables (visserie, chevilles…)
       - Pour chaque poste, créez :
         - **Titre de la tâche** (ex. **Démolition de carrelage existant**)
         - **Description détaillée** de l’opération (méthode, outils, tri et évacuation des déchets)
         - **Matériaux** (désignation, quantités, PU HT, sous-total)
         - **Main-d’œuvre** (type de professionnel, heures, tarif horaire HT, sous-total)
         - **Consommables** (lot visserie, chevilles, protections…)
       - Calculez et affichez les sous-totaux HT.

    2. **Présentation HTML imprimable & accessible**
       - Retournez uniquement du HTML propre (pas de Markdown), avec :
         - DocType, <meta charset="UTF-8"> et <title>
         - Styles embarqués (voir chunk CSS ci-dessous)
         - Balises sémantiques (<header>, <main>, <section>, <footer>) et rôles ARIA
         - Numérotation automatique des pages en pied de page
         - Classe .page-break pour forcer les sauts de page

       ```css
       @media print { .page-break { page-break-after: always; } }
       header, footer { width: 100%; text-align: center; font-size: 9pt; color: #666; }
       footer { position: fixed; bottom: 10mm; }
       body { font-family: 'Open Sans', sans-serif; margin: 20mm; }
       .header { display: flex; justify-content: space-between; align-items: center; }
       .logo { width: 50mm; height: 50mm; border: 1px solid #ccc; }
       h1,h2,h3 { margin: 0; padding: 0; }
       table { width: 100%; border-collapse: collapse; margin-top: 10px; }
       th, td { padding: 4px 8px; border-bottom: 1px solid #ddd; text-align: left; }
       .right { text-align: right; }
       .bold { font-weight: bold; }
       .small { font-size: 10pt; }
       ```

       *(Insérer ici la structure HTML complète, sans modifier le back-tick triple)*

    3. **Ajustements et validation**
       - Présente l’aperçu HTML et demande :
         “Voici votre devis préliminaire. Souhaitez-vous ajuster une tâche, ajouter/supprimer une clause ou modifier un prix ?”
       - Si “oui”, interrogez sur les modifications ; sinon poursuivez.

    4. **Collecte de l’en-tête PDF & finalisation**
       - Demandez : nom, adresse, téléphone, e-mail, SIRET, logo (upload).
       - Validez les clauses cochées.

    5. **Génération du PDF A4 fillable**
       - Marges 20 mm, Open Sans 11 pt, sommaire automatique, pages numérotées.
       - Champs PDF éditables : signatures artisan & client, date de signature.
       - QR code dans le pied de page renvoyant à la version en ligne.
       - Nom de fichier : Devis_<Client>_<Projet>_<YYYYMMDD>.pdf

    Critères de réussite :
    - Rendu HTML et PDF impeccables, parfaitement calibrés pour impression A4
    - Structure sémantique et accessible (ARIA)
    - Descriptions détaillées, calculs HT/TVA/TTC, planning et clauses complètes
    - Effet “wow” dès l’aperçu pré-rempli, ajustable en temps réel
    - PDF fillable avec page breaks, numéros de page et QR code pour accès en ligne
  PROMPT
end
end
