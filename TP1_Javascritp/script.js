
window.addEventListener("load", function () {

    console.log('Page et ressources intégralement chargées');


    var toc = document.querySelector("#toc");
    var titres = document.querySelectorAll("h1");

    var titreSommaire = document.createElement("p");
    titreSommaire.textContent = "Sommaire";
    toc.appendChild(titreSommaire);


    var liste = document.createElement("ul");

    for (var i = 0; i < titres.length; i++) {

        titres[i].id = "titre" + i;

        var li = document.createElement("li");
        var lien = document.createElement("a");

        lien.href = "#titre" + i;


        lien.textContent = titres[i].textContent;

        li.appendChild(lien);
        liste.appendChild(li);
    }

    toc.appendChild(liste);

});

