import java.io.File;
import java.util.Arrays;


public class ListerRepertoire {

    public static void main(String[] args) {
        
        if (args.length == 0) {
            System.out.println("Erreur : Aucun répertoire spécifié en ligne de commande.");
            System.out.println("Usage  : java ListerRepertoire <chemin_du_repertoire>");
            return;
        }

        String chemin = args[0];

        File repertoire = new File(chemin);

        if (!repertoire.exists()) {
            System.out.println("Erreur : Le chemin spécifié n'existe pas : " + chemin);
            return;
        }
        if (!repertoire.isDirectory()) {
            System.out.println("Erreur : Le chemin spécifié n'est pas un répertoire : " + chemin);
            return;
        }

        String[] listeFichiers = repertoire.list();

        if (listeFichiers == null || listeFichiers.length == 0) {
            System.out.println("Le répertoire \"" + chemin + "\" est vide.");
            return;
        }

        Arrays.sort(listeFichiers, String.CASE_INSENSITIVE_ORDER);

        int nbFichiers = 0;
        int nbRepertoires = 0;
        long tailleTotaleFichiers = 0;

        System.out.println("Contenu du répertoire : " + repertoire.getAbsolutePath());
        System.out.println("----------------------------------------------------------------------");
        System.out.printf("%-35s | %-12s | %-15s%n", "Nom", "Type", "Taille (octets)");
        System.out.println("----------------------------------------------------------------------");

        for (int i = 0; i < listeFichiers.length; i++) {
            String nom = listeFichiers[i];
            File element = new File(repertoire, nom);

            if (element.isDirectory()) {
                nbRepertoires++;
                System.out.printf("%-35s | %-12s | %-15s%n", nom, "[Répertoire]", "-");
            } else {
                nbFichiers++;
                long taille = element.length();
                tailleTotaleFichiers += taille;
                System.out.printf("%-35s | %-12s | %-15d%n", nom, "Fichier", taille);
            }
        }
        System.out.println("----------------------------------------------------------------------");
        System.out.println("Statistiques finales :");
        System.out.println("- Nombre de fichiers    : " + nbFichiers);
        System.out.println("- Nombre de répertoires : " + nbRepertoires);
        System.out.println("- Taille totale fichiers: " + tailleTotaleFichiers + " octets");
        System.out.println("----------------------------------------------------------------------");
    }
}
