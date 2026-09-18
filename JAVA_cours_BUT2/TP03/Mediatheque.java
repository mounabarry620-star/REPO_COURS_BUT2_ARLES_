import java.util.ArrayList;
import java.util.Scanner;

public class Mediatheque {
    private ArrayList<Ouvrage> listeOuvrages;

    public Mediatheque() {
        this.listeOuvrages = new ArrayList<Ouvrage>();
    }

    public ArrayList<Ouvrage> getListeOuvrages() {
        return this.listeOuvrages;
    }

    public void ajouterOuvrage() {
        Scanner clavier = new Scanner(System.in);
        ajouterOuvrage(clavier);
    }

    public void ajouterOuvrage(Scanner clavier) {
        System.out.println("\nQuel type d'ouvrage voulez-vous ajouter ?");
        System.out.println("1. Livre");
        System.out.println("2. DVD");
        System.out.print("Votre choix : ");
        int type = clavier.nextInt();
        clavier.nextLine();

        if (type != 1 && type != 2) {
            System.out.println("Type d'ouvrage invalide.");
            return;
        }

        System.out.print("Numéro d'identification : ");
        int numero = clavier.nextInt();
        clavier.nextLine();

        System.out.print("L'ouvrage est-il emprunté ? (oui/non) : ");
        String repEmprunt = clavier.nextLine();
        boolean emprunte = repEmprunt.equalsIgnoreCase("oui");

        if (type == 1) {
            System.out.print("Titre du livre : ");
            String titre = clavier.nextLine();
            System.out.print("Nom de l'auteur : ");
            String auteur = clavier.nextLine();

            Livre livre = new Livre(numero, emprunte, titre, auteur);
            this.listeOuvrages.add(livre);
            System.out.println("Livre ajouté avec succès !");
        } else {
            System.out.print("Titre du DVD : ");
            String titre = clavier.nextLine();
            System.out.print("Durée du DVD (en minutes) : ");
            int duree = clavier.nextInt();
            clavier.nextLine();

            DVD dvd = new DVD(numero, emprunte, titre, duree);
            this.listeOuvrages.add(dvd);
            System.out.println("DVD ajouté avec succès !");
        }
    }

    public void afficherOuvrages() {
        if (this.listeOuvrages.size() == 0) {
            System.out.println("\nAucun ouvrage dans la médiathèque.");
            return;
        }

        System.out.println("\n===== Liste des ouvrages de la médiathèque (" + this.listeOuvrages.size() + ") =====");
        for (int i = 0; i < this.listeOuvrages.size(); i++) {
            this.listeOuvrages.get(i).afficher();
            System.out.println("----------------------------------------");
        }
    }
}
