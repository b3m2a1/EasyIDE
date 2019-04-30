
// Script to open and close sidebar
function acc_open() {
    document.getElementById("tocbar").style.display = "block";
    document.getElementById("tocoverlay").style.display = "block";
    document.getElementById("tocopener").onclick = acc_close;
}

function acc_close() {
    document.getElementById("tocbar").style.display = "none";
    document.getElementById("tocoverlay").style.display = "none";
    document.getElementById("tocopener").onclick = acc_open;
}
