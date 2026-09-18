import java.util.ArrayList;
import java.util.Scanner;

public class principal {

    public static void main(String[] args) {

        ArrayList<Etudiant> liste = new ArrayList<Etudiant>();
        saisirEtudiant(liste);

        System.out.println("\nListe des etudiants :");
        afficher(liste);

        System.out.println("\nMeilleur etudiant :");
        Etudiant top = meilleureMoyenne(liste);
        if (top != null) {
            top.affiche();
        }

        System.out.println("\nEtudiants avec moyenne < 10 :");
        ArrayList<Etudiant> moinsDe10 = etudiantsMoyenneInferieure10(liste);
        afficher(moinsDe10);

        System.out.println("\nTri par nom croissant :");
        trierParNom(liste);
        afficher(liste);

        System.out.println("\nTri par moyenne decroissante :");
        trierParMoyenneDecroissante(liste);
        afficher(liste);
    }

    public static void saisirEtudiant(ArrayList<Etudiant> liste) {
        Scanner lectureClavier = new Scanner(System.in);
        System.out.print("Combien d'etudiants voulez-vous saisir ? ");
        int nb = lectureClavier.nextInt();
        lectureClavier.nextLine(); 

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

    public static void afficher(ArrayList<Etudiant> liste) {
        if (liste.size() == 0) {
            System.out.println("(Liste vide)");
            return;
        }
        for (int i = 0; i < liste.size(); i++) {
            liste.get(i).affiche();
        }
    }

    public static Etudiant meilleureMoyenne(ArrayList<Etudiant> liste) {
        if (liste == null || liste.size() == 0) {
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

    public static ArrayList<Etudiant> etudiantsMoyenneInferieure10(ArrayList<Etudiant> liste) {
        ArrayList<Etudiant> resultat = new ArrayList<Etudiant>();
        for (int i = 0; i < liste.size(); i++) {
            if (liste.get(i).getMoyenne() < 10.0) {
                resultat.add(liste.get(i));
            }
        }
        return resultat;
    }


    public static void trierParNom(ArrayList<Etudiant> liste) {
        liste.sort(new TriParNom());
    }


    public static void trierParMoyenneDecroissante(ArrayList<Etudiant> liste) {
        liste.sort(new TriParMoyenne());
    }
}