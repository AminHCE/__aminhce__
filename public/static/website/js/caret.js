let cursor;
window.onload = init;

function $(elid) {
    return document.getElementById(elid);
}

function init() {
    cursor = $("cursor");
    cursor.style.left = "0px";
}

function typeIt(from, e) {
    let tw = from.value;
    let w = $("typer");
    if (!pw)
        w.innerHTML = tw.replace(/\n/g, '');
}

function moveIt(count, e) {
    let keycode = e.keyCode || e.which;
    if (keycode == 37 && parseInt(cursor.style.left) >= (0 - ((count - 1) * 10))) {
        cursor.style.left = parseInt(cursor.style.left) - 10 + "px";
    } else if (keycode == 39 && (parseInt(cursor.style.left) + 10) <= 0) {
        cursor.style.left = parseInt(cursor.style.left) + 10 + "px";
    }
}