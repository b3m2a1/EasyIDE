// Accordion
function myAccFunc() {
    var x = document.getElementById("demoAcc");
    if (x.className.indexOf("w3-show") == -1) {
        x.className += " w3-show";
    } else {
        x.className = x.className.replace(" w3-show", "");
    }
}

// Script to open and close sidebar
function acc_open() {
    document.getElementById("accSidebar").style.display = "block";
    document.getElementById("accOverlay").style.display = "block";
}

function acc_close() {
    document.getElementById("accSidebar").style.display = "none";
    document.getElementById("accOverlay").style.display = "none";
}
