import java.io.Serializable;

public class Compte implements Serializable {
    private static final long serialVersionUID = 1L;
    private String proprietaire;
    private double solde;
    public Compte(String proprietaire, double solde) {
        this.proprietaire = proprietaire;
        this.solde = solde;
    }

    public String getProprietaire() {
        return this.proprietaire;
    }

    public void setProprietaire(String proprietaire) {
        this.proprietaire = proprietaire;
    }
    public double getSolde() {
        return this.solde;
    }
    public void setSolde(double solde) {
        this.solde = solde;
    }
    public void afficher() {
        System.out.println("Titulaire : " + this.proprietaire + " | Solde : " + this.solde + " €");
    }
    @Override
    public String toString() {
        return "Compte[proprietaire=" + this.proprietaire + ", solde=" + this.solde + " €]";
    }
}
