import java.util.ArrayList;
import java.util.Scanner;

public class principal {

    // 1. Méthode principale main() : TOUJOURS placée en premier comme dans le cours (Chapitre 2 diapo 23 et Chapitre 6 diapo 53)
    public static void main(String[] args) {
        // Question 1 : Déclaration de la liste d'étudiants (ArrayList)
        ArrayList<Etudiant> liste = new ArrayList<Etudiant>();

        // Question 2 : Saisie des étudiants au clavier
        saisirEtudiant(liste);

        // Question 3 : Affichage de tous les étudiants
        System.out.println("\n=== Liste des etudiants ===");
        afficher(liste);

        // Question 4 : Trouver et afficher le meilleur étudiant
        System.out.println("\n=== Meilleur etudiant ===");
        Etudiant top = meilleureMoyenne(liste);
        if (top != null) {
            top.affiche();
        }

        // Question 5 : Trouver et afficher les étudiants avec moyenne < 10
        System.out.println("\n=== Etudiants avec moyenne < 10 ===");
        ArrayList<Etudiant> moinsDe10 = etudiantsMoyenneInferieure10(liste);
        afficher(moinsDe10);

        // Question 6 : Trier et afficher par nom croissant
        System.out.println("\n=== Tri par nom croissant ===");
        trierParNom(liste);
        afficher(liste);

        // Question 7 : Trier et afficher par moyenne décroissante
        System.out.println("\n=== Tri par moyenne decroissante ===");
        trierParMoyenneDecroissante(liste);
        afficher(liste);
    }

    // 2. Fonction permettant de remplir la liste d'étudiants (Chapitre 2 diapos 14-15)
    public static void saisirEtudiant(ArrayList<Etudiant> liste) {
        Scanner lectureClavier = new Scanner(System.in);

        System.out.print("Combien d'etudiants voulez-vous saisir ? ");
        int nb = lectureClavier.nextInt();
        lectureClavier.nextLine(); // pour consommer le retour à la ligne

        for (int i = 0; i < nb; i++) {
            System.out.println("Etudiant n°" + (i + 1) + " :");
            System.out.print("Nom : ");
            String nom = lectureClavier.nextLine();

            System.out.print("Prenom : ");
            String prenom = lectureClavier.nextLine();

            System.out.print("Moyenne : ");
            float moyenne = Float.parseFloat(lectureClavier.nextLine().replace(',', '.'));

            liste.add(new Etudiant(nom, prenom, moyenne));
        }
    }

    // 3. Fonction affichant une liste d'étudiants reçue en paramètre (Chapitre 6 diapo 53)
    public static void afficher(ArrayList<Etudiant> liste) {
        if (liste.isEmpty()) {
            System.out.println("(Liste vide)");
            return;
        }
        for (int i = 0; i < liste.size(); i++) {
            liste.get(i).affiche();
        }
    }

    // 4. Fonction qui retourne l'étudiant ayant la meilleure moyenne
    public static Etudiant meilleureMoyenne(ArrayList<Etudiant> liste) {
        if (liste == null || liste.isEmpty()) {
            return null;
        }
        Etudiant max = liste.get(0);
        for (int i = 1; i < liste.size(); i++) {
            if (liste.get(i).getMoyenne() > max.getMoyenne()) {
                max = liste.get(i);
            }
        }
        return max;
    }

    // 5. Fonction qui retourne une liste d'étudiants ayant des moyennes < 10
    public static ArrayList<Etudiant> etudiantsMoyenneInferieure10(ArrayList<Etudiant> liste) {
        ArrayList<Etudiant> resultat = new ArrayList<Etudiant>();
        for (int i = 0; i < liste.size(); i++) {
            if (liste.get(i).getMoyenne() < 10.0f) {
                resultat.add(liste.get(i));
            }
        }
        return resultat;
    }

    // 6. Fonction triant selon l'ordre croissant des noms (Chapitre 6 diapo 52)
    public static void trierParNom(ArrayList<Etudiant> liste) {
        liste.sort(new TriParNom());
    }

    // 7. Fonction triant selon l'ordre décroissant des moyennes (Chapitre 6 diapo 52)
    public static void trierParMoyenneDecroissante(ArrayList<Etudiant> liste) {
        liste.sort(new TriParMoyenne());
    }
}