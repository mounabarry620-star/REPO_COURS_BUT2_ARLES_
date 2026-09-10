import java.util.Comparator;

public class TriParMoyenne implements Comparator<Etudiant> {
    public int compare(Etudiant a, Etudiant b) {
        if (a.getMoyenne() > b.getMoyenne()) {
            return -1;
        } else if (a.getMoyenne() < b.getMoyenne()) {
            return 1;
        } else {
            return 0;
        }
    }
}
