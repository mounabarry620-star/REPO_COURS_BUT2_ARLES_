public class DVD extends Ouvrage {
    private String titre;
    private int duree;

    public DVD(int numero, boolean emprunte, String titre, int duree) {
        super(numero, emprunte);
        this.titre = titre;
        this.duree = duree;
    }

    public String getTitre() {
        return this.titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public int getDuree() {
        return this.duree;
    }

    public void setDuree(int duree) {
        this.duree = duree;
    }

    @Override
    public void afficher() {
        System.out.println("--- DVD ---");
        super.afficher();
        System.out.println("Titre : " + this.titre);
        System.out.println("Durée : " + this.duree + " minutes");
    }
}
