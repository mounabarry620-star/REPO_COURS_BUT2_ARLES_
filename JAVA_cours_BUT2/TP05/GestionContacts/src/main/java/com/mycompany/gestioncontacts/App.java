package com.mycompany.gestioncontacts;

import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Priority;
import javafx.scene.layout.VBox;
import javafx.stage.FileChooser;
import javafx.stage.Stage;

import java.io.*;

/**
 * JavaFX App
 */
public class App extends Application {

    // Ligne d'en-tete du fichier CSV (la meme pour l'export et l'import)
    private static final String ENTETE = "nom;prénom;email;téléphone";

    // Liste observable des contacts : toute modification est repercutee dans la TableView
    private ObservableList<Contact> contacts = FXCollections.observableArrayList();

    @Override
    public void start(Stage stage) {

        // Q3 : titre de la fenetre
        stage.setTitle("Gestion de contacts");

        // Q4 : layout principal
        BorderPane borderPane = new BorderPane();

        // Q8 : la table et ses 4 colonnes
        TableView<Contact> table = new TableView<>();

        TableColumn<Contact, String> lastNameCol = new TableColumn<>("Nom");
        lastNameCol.setCellValueFactory(new PropertyValueFactory<>("lastName"));

        TableColumn<Contact, String> firstNameCol = new TableColumn<>("Prénom");
        firstNameCol.setCellValueFactory(new PropertyValueFactory<>("firstName"));

        TableColumn<Contact, String> mailCol = new TableColumn<>("Email");
        mailCol.setCellValueFactory(new PropertyValueFactory<>("email"));

        TableColumn<Contact, String> phoneCol = new TableColumn<>("Téléphone");
        phoneCol.setCellValueFactory(new PropertyValueFactory<>("phone"));

        table.getColumns().addAll(lastNameCol, firstNameCol, mailCol, phoneCol);
        table.setItems(contacts);

        borderPane.setCenter(table);

        // Q9 et Q10 : la barre d'action en bas de la fenetre
        Button buttonAdd = new Button("Ajouter");
        Button buttonModify = new Button("Modifier");
        Button buttonDelete = new Button("Supprimer");
        Button buttonImport = new Button("Importer");
        Button buttonExport = new Button("Exporter");

        HBox hbox = new HBox(8);
        hbox.getChildren().addAll(buttonAdd, buttonModify, buttonDelete, buttonImport, buttonExport);

        buttonAdd.setMaxWidth(Double.MAX_VALUE);
        HBox.setHgrow(buttonAdd, Priority.ALWAYS);
        buttonModify.setMaxWidth(Double.MAX_VALUE);
        HBox.setHgrow(buttonModify, Priority.ALWAYS);
        buttonDelete.setMaxWidth(Double.MAX_VALUE);
        HBox.setHgrow(buttonDelete, Priority.ALWAYS);
        buttonImport.setMaxWidth(Double.MAX_VALUE);
        HBox.setHgrow(buttonImport, Priority.ALWAYS);
        buttonExport.setMaxWidth(Double.MAX_VALUE);
        HBox.setHgrow(buttonExport, Priority.ALWAYS);

        borderPane.setBottom(hbox);

        // Q12 : bouton Ajouter
        buttonAdd.setOnAction(e -> openEditor(null));

        // Q13 : bouton Modifier
        buttonModify.setOnAction(e -> {
            Contact c = table.getSelectionModel().getSelectedItem();
            openEditor(c);
        });
        buttonModify.disableProperty().bind(
            table.getSelectionModel().selectedItemProperty().isNull()
        );

        // Q14 : bouton Supprimer
        buttonDelete.setOnAction(e -> {
            Contact c = table.getSelectionModel().getSelectedItem();
            contacts.remove(c);
        });
        buttonDelete.disableProperty().bind(
            table.getSelectionModel().selectedItemProperty().isNull()
        );

        // Q15 et Q16 : boutons Exporter et Importer
        buttonExport.setOnAction(e -> exporter(stage));
        buttonImport.setOnAction(e -> importer(stage));

        var scene = new Scene(borderPane, 640, 480);
        stage.setScene(scene);
        stage.show();
    }

    // Q11 : fenetre de saisie / modification d'un contact
    // toEdit vaut null pour un nouveau contact
    private void openEditor(Contact toEdit) {
        Stage dlg = new Stage();

        Label labelLastName = new Label("Nom :");
        Label labelFirstName = new Label("Prénom :");
        Label labelEmail = new Label("Email :");
        Label labelPhone = new Label("Téléphone :");

        TextField textfieldLastName = new TextField();
        TextField textfieldFirstName = new TextField();
        TextField textfieldEmail = new TextField();
        TextField textfieldPhone = new TextField();

        // Si on modifie un contact, on pre-remplit les champs
        if (toEdit != null) {
            textfieldLastName.setText(toEdit.getLastName());
            textfieldFirstName.setText(toEdit.getFirstName());
            textfieldEmail.setText(toEdit.getEmail());
            textfieldPhone.setText(toEdit.getPhone());
        }

        // Les labels dans la colonne 0, les champs dans la colonne 1
        GridPane gridPane = new GridPane();
        gridPane.add(labelLastName, 0, 0);
        gridPane.add(textfieldLastName, 1, 0);
        gridPane.add(labelFirstName, 0, 1);
        gridPane.add(textfieldFirstName, 1, 1);
        gridPane.add(labelEmail, 0, 2);
        gridPane.add(textfieldEmail, 1, 2);
        gridPane.add(labelPhone, 0, 3);
        gridPane.add(textfieldPhone, 1, 3);

        Button okBtn = new Button("OK");
        Button cancelBtn = new Button("Annuler");
        HBox hboxBoutons = new HBox(8);
        hboxBoutons.getChildren().addAll(okBtn, cancelBtn);

        // Bouton Annuler : on ferme simplement la fenetre
        cancelBtn.setOnAction(e -> dlg.close());

        // Bouton OK : on recupere les valeurs saisies
        okBtn.setOnAction(e -> {
            String ln = textfieldLastName.getText();
            String fn = textfieldFirstName.getText();
            String em = textfieldEmail.getText();
            String ph = textfieldPhone.getText();

            if (toEdit == null) {
                // Creation d'un nouveau contact
                contacts.add(new Contact(ln, fn, em, ph));
            } else {
                // Modification du contact existant
                toEdit.setLastName(ln);
                toEdit.setFirstName(fn);
                toEdit.setEmail(em);
                toEdit.setPhone(ph);
            }
            dlg.close();
        });

        // La grille au-dessus, les boutons en dessous
        VBox root = new VBox(10, gridPane, hboxBoutons);
        Scene scene = new Scene(root, 320, 180);
        dlg.setScene(scene);

        if (toEdit == null) {
            dlg.setTitle("Ajouter un contact");
        } else {
            dlg.setTitle("Modifier un contact");
        }
        dlg.show();
    }

    // Q15 : export des contacts dans un fichier CSV
    private void exporter(Stage stage) {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Exporter les contacts");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("Fichiers CSV", "*.csv"));

        File f = fileChooser.showSaveDialog(stage);
        if (f != null) {
            ecrireFichier(f);
        }
    }

    private void ecrireFichier(File f) {
        BufferedWriter fW;
        try {
            fW = new BufferedWriter(new FileWriter(f));

            // Premiere ligne : l'en-tete
            fW.write(ENTETE, 0, ENTETE.length());
            fW.newLine();

            // Puis une ligne par contact
            for (int i = 0; i < contacts.size(); i++) {
                Contact c = contacts.get(i);
                String ligne = c.getLastName() + ";" + c.getFirstName() + ";"
                             + c.getEmail() + ";" + c.getPhone();
                fW.write(ligne, 0, ligne.length());
                fW.newLine();
            }
            fW.close();
        } catch (IOException e) {
            afficherErreur("Impossible d'écrire le fichier : " + e.getMessage());
        }
    }

    // Q16 : import des contacts depuis un fichier CSV
    private void importer(Stage stage) {
        FileChooser fileChooser = new FileChooser();
        fileChooser.setTitle("Importer des contacts");
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("Fichiers CSV", "*.csv"));

        File f = fileChooser.showOpenDialog(stage);
        if (f != null) {
            lireFichier(f);
        }
    }

    private void lireFichier(File f) {
        BufferedReader fR;
        try {
            fR = new BufferedReader(new FileReader(f));

            // On verifie la premiere ligne
            String ligne = fR.readLine();
            if (ligne == null || !ligne.equals(ENTETE)) {
                fR.close();
                afficherErreur("Ce fichier n'est pas un fichier de contacts.");
                return;
            }

            // On lit les lignes suivantes une par une
            ligne = fR.readLine();
            while (ligne != null) {
                if (ligne.length() > 0) {
                    contacts.add(decouperLigne(ligne));
                }
                ligne = fR.readLine();
            }
            fR.close();
        } catch (IOException | StringIndexOutOfBoundsException e) {
            afficherErreur("Erreur de lecture du fichier : " + e.getMessage());
        }
    }

    // Transforme "nom;prenom;email;telephone" en objet Contact
    private Contact decouperLigne(String ligne) {
        int p1 = ligne.indexOf(";");
        String ln = ligne.substring(0, p1);
        String reste = ligne.substring(p1 + 1, ligne.length());

        int p2 = reste.indexOf(";");
        String fn = reste.substring(0, p2);
        reste = reste.substring(p2 + 1, reste.length());

        int p3 = reste.indexOf(";");
        String em = reste.substring(0, p3);
        String ph = reste.substring(p3 + 1, reste.length());

        return new Contact(ln, fn, em, ph);
    }

    // Affiche une boite de dialogue d'erreur
    private void afficherErreur(String message) {
        Alert alert = new Alert(AlertType.ERROR);
        alert.setTitle("Erreur");
        alert.setHeaderText("Erreur");
        alert.setContentText(message);
        alert.showAndWait();
    }

    public static void main(String[] args) {
        launch();
    }

}
