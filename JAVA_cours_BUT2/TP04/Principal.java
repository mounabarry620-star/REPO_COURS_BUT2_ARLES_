import java.util.Scanner;

public class Principal {

    public static void main(String[] args) {
        Scanner clavier = new Scanner(System.in);
        Banque banque = new Banque();
        int choix = 0;

        do {
            System.out.println("\n==============================================");
            System.out.println("          GESTION DE LA BANQUE - MENU         ");
            System.out.println("==============================================");
            System.out.println("1. Ajouter un nouveau compte");
            System.out.println("2. Afficher le compte d'un client (par son nom)");
            System.out.println("3. Afficher l'ensemble des comptes");
            System.out.println("4. Sauvegarder les comptes dans un fichier");
            System.out.println("5. Charger les comptes depuis un fichier");
            System.out.println("6. Quitter");
            System.out.println("==============================================");
            System.out.print("Votre choix : ");

            if (!clavier.hasNextInt()) {
                System.out.println("Veuillez saisir un numéro valide entre 1 et 6.");
                clavier.nextLine();
                continue;
            }

            choix = clavier.nextInt();
            clavier.nextLine();

            switch (choix) {
                case 1:
                    System.out.println("\n--- Ajout d'un compte ---");
                    System.out.print("Nom du propriétaire : ");
                    String nom = clavier.nextLine().trim();

                    double solde = 0.0;
                    boolean soldeValide = false;
                    while (!soldeValide) {
                        System.out.print("Solde initial (€) : ");
                        String saisieSolde = clavier.nextLine().trim().replace(',', '.');
                        try {
                            solde = Double.parseDouble(saisieSolde);
                            soldeValide = true;
                        } catch (NumberFormatException e) {
                            System.out.println(
                                    "Erreur : veuillez entrer un montant numérique valide (ex: 1500 ou 1500.50).");
                        }
                    }

                    Compte nouveauCompte = new Compte(nom, solde);
                    banque.ajouterCompte(nouveauCompte);
                    break;

                case 2:
                    System.out.println("\n--- Recherche de compte ---");
                    System.out.print("Entrez le nom du client : ");
                    String nomCherche = clavier.nextLine().trim();
                    banque.afficherCompteClient(nomCherche);
                    break;

                case 3:
                    banque.afficherComptes();
                    break;

                case 4:
                    System.out.println("\n--- Sauvegarde de la banque ---");
                    System.out.print("Nom du fichier de sauvegarde (ex: banque.dat) : ");
                    String nomFichierSauvegarde = clavier.nextLine().trim();

                    banque.sauvegarder(nomFichierSauvegarde);
                    break;

                case 5:
                    System.out.println("\n--- Chargement de la banque ---");
                    System.out.print("Nom du fichier à charger (ex: banque.dat) : ");
                    String nomFichierChargement = clavier.nextLine().trim();

                    Banque banqueChargee = Banque.charger(nomFichierChargement);
                    if (banqueChargee != null) {
                        banque = banqueChargee;
                    }
                    break;

                case 6:
                    System.out.println("\nFermeture de l'application. Au revoir !");
                    break;

                default:
                    System.out.println("Option inexistante. Veuillez choisir une option entre 1 et 6.");
            }

        } while (choix != 6);

        clavier.close();
    }
}
