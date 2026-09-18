public class Etudiant {
    private String nom;
    private String prenom;
    private float moyenne;

    public Etudiant(String nom, String prenom, float moyenne) {
        this.nom = nom;
        this.prenom = prenom;
        this.moyenne = moyenne;
    }

    public void affiche() {
        System.out.println(this.prenom + " " + this.nom + " a une moyenne de " + this.moyenne);
    }
    public String getNom() {
        return this.nom;
    }

    public String getPrenom() {
        return this.prenom;
    }

    public float getMoyenne() {
        return this.moyenne;
    }
}
