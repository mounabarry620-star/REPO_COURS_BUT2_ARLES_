public class Ouvrage {
    private int numero;
    protected boolean emprunte;

    public Ouvrage(int numero, boolean emprunte) {
        this.numero = numero;
        this.emprunte = emprunte;
    }

    public int getNumero() {
        return this.numero;
    }

    public void setNumero(int numero) {
        this.numero = numero;
    }

    public boolean getEmprunte() {
        return this.emprunte;
    }

    public boolean isEmprunte() {
        return this.emprunte;
    }

    public void setEmprunte(boolean emprunte) {
        this.emprunte = emprunte;
    }

    public void afficher() {
        System.out.println("Numéro d'identification : " + this.numero);
        if (this.emprunte) {
            System.out.println("Statut : Emprunté");
        } else {
            System.out.println("Statut : Disponible");
        }
    }
}
