import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.ArrayList;


public class Banque implements Serializable {


    private static final long serialVersionUID = 1L;

    private ArrayList<Compte> listeComptes;

    public Banque() {
        this.listeComptes = new ArrayList<Compte>();
    }

    public ArrayList<Compte> getListeComptes() {
        return this.listeComptes;
    }

    public void ajouterCompte(Compte compte) {
        if (compte != null) {
            this.listeComptes.add(compte);
            System.out.println("Compte de " + compte.getProprietaire() + " ajouté avec succès !");
        }
    }


    public Compte chercherCompte(String nom) {
        for (int i = 0; i < this.listeComptes.size(); i++) {
            Compte c = this.listeComptes.get(i);
            if (c.getProprietaire().equalsIgnoreCase(nom)) {
                return c;
            }
        }
        return null;
    }

    public void afficherComptes() {
        if (this.listeComptes.size() == 0) {
            System.out.println("Aucun compte enregistré dans la banque.");
            return;
        }

        System.out.println("\n===== Liste de tous les comptes bancaires (" + this.listeComptes.size() + ") =====");
        for (int i = 0; i < this.listeComptes.size(); i++) {
            System.out.print("[" + (i + 1) + "] ");
            this.listeComptes.get(i).afficher();
        }
    }


    public void afficherCompteClient(String nom) {
        Compte c = chercherCompte(nom);
        if (c != null) {
            System.out.println("\n--- Compte trouvé ---");
            c.afficher();
        } else {
            System.out.println("Aucun compte trouvé pour le client \"" + nom + "\".");
        }
    }
    public boolean sauvegarder(String nomFichier) {
        ObjectOutputStream fWo = null;
        try {

            fWo = new ObjectOutputStream(new FileOutputStream(nomFichier));
            fWo.writeObject(this);
            fWo.close();
            System.out.println("Sauvegarde réussie dans le fichier : " + nomFichier);
            return true;
        } catch (IOException e) {
            System.out.println("Erreur lors de la sauvegarde : " + e.getMessage());
            return false;
        }
    }


    public static Banque charger(String nomFichier) {
        File f = new File(nomFichier);

        if (!f.exists()) {
            System.out.println("Erreur : Le fichier \"" + nomFichier + "\" n'existe pas.");
            return null;
        }

        ObjectInputStream fRo = null;
        try {
            fRo = new ObjectInputStream(new FileInputStream(f));
            Banque banqueChargee = (Banque) fRo.readObject();
            fRo.close();
            System.out.println("Chargement réussi depuis le fichier : " + nomFichier);
            return banqueChargee;
        } catch (IOException e) {
            System.out.println("Erreur d'entrée/sortie lors du chargement : " + e.getMessage());
            return null;
        } catch (ClassNotFoundException e) {
            System.out.println("Erreur de type d'objet : " + e.getMessage());
            return null;
        }
    }
}
