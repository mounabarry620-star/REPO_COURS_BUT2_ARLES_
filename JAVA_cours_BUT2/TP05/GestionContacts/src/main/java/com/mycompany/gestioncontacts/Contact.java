package com.mycompany.gestioncontacts;

import javafx.beans.property.SimpleStringProperty;
import javafx.beans.property.StringProperty;

public class Contact {

    // DONNEES MEMBRES : des StringProperty pour qu'elles soient observables
    private StringProperty lastName = new SimpleStringProperty("");
    private StringProperty firstName = new SimpleStringProperty("");
    private StringProperty email = new SimpleStringProperty("");
    private StringProperty phone = new SimpleStringProperty("");

    // Constructeur : on recoit des String et on les range dans les StringProperty
    public Contact(String ln, String fn, String em, String ph) {
        lastName.set(ln);
        firstName.set(fn);
        email.set(em);
        phone.set(ph);
    }

    // Nom
    public String getLastName() { return lastName.get(); }
    public void setLastName(String v) { lastName.set(v); }
    public StringProperty lastNameProperty() { return lastName; }

    // Prenom
    public String getFirstName() { return firstName.get(); }
    public void setFirstName(String v) { firstName.set(v); }
    public StringProperty firstNameProperty() { return firstName; }

    // Email
    public String getEmail() { return email.get(); }
    public void setEmail(String v) { email.set(v); }
    public StringProperty emailProperty() { return email; }

    // Telephone
    public String getPhone() { return phone.get(); }
    public void setPhone(String v) { phone.set(v); }
    public StringProperty phoneProperty() { return phone; }
}
