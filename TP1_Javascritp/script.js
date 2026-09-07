document.addEventListener("DOMContentLoaded", event => {


    let toc = document.querySelector("#toc");


    let titres = document.querySelectorAll("h1");


    let titreSommaire = document.createElement("p");
    titreSommaire.textContent = "Sommaire";
    toc.appendChild(titreSommaire);
    let liste = document.createElement("ol");

    for (let i = 0; i < titres.length; i++) {


        titres[i].id = "titre" + i;

        let li = document.createElement("li");

        let lien = document.createElement("a");
        lien.href = "#titre" + i;
        lien.textContent = titres[i].textContent;

        li.appendChild(lien);
        liste.appendChild(li);
    }
    toc.appendChild(liste);

});
