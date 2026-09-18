import java.util.Comparator;

// Conforme au Chapitre 6 diapo 52
public class TriParNom implements Comparator<Etudiant> {
    public int compare(Etudiant a, Etudiant b) {
        return a.getNom().compareToIgnoreCase(b.getNom());
    }
}
