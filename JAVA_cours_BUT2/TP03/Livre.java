public class Livre extends Ouvrage {
    private String titre;
    private String auteur;

    public Livre(int numero, boolean emprunte, String titre, String auteur) {
        super(numero, emprunte);
        this.titre = titre;
        this.auteur = auteur;
    }

    public String getTitre() {
        return this.titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public String getAuteur() {
        return this.auteur;
    }

    public void setAuteur(String auteur) {
        this.auteur = auteur;
    }

    @Override
    public void afficher() {
        System.out.println("--- Livre ---");
        super.afficher();
        System.out.println("Titre : " + this.titre);
        System.out.println("Auteur : " + this.auteur);
    }
}
