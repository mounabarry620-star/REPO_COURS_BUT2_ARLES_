import java.util.Scanner;

public class Principal {
    public static void main(String[] args) {
        Mediatheque mediatheque = new Mediatheque();
        Scanner clavier = new Scanner(System.in);
        byte choix = 0;

        do {
            System.out.println("\n=== Menu Médiathèque ===");
            System.out.println("1. Ajouter un ouvrage");
            System.out.println("2. Afficher la liste des ouvrages");
            System.out.println("3. Quitter");
            System.out.print("Votre choix : ");

            choix = clavier.nextByte();
            clavier.nextLine(); // Consomme le retour à la ligne

            switch (choix) {
                case 1:
                    mediatheque.ajouterOuvrage(clavier);
                    break;
                case 2:
                    mediatheque.afficherOuvrages();
                    break;
                case 3:
                    System.out.println("Au revoir !");
                    break;
                default:
                    System.out.println("Option inexistante.");
            }
        } while (choix != 3);
    }
}
