let terminal = document.getElementById("terminal");
let command = document.getElementById("typer");
let textarea = document.getElementById("texter");
let before = document.getElementById("before");

let git = 0;
let pw = false;
let commands = [];

setTimeout(function() {
    loopLines(banner, "", 150);
    textarea.focus();
}, 100);

window.addEventListener("keyup", enterKey);

//Easter Egg
console.log(
    "%cAminHCE rm -rf",
    "color: #519975; font-weight: bold; font-size: 18px;"
);

//init/////////////////////////////
textarea.value = "";
command.innerHTML = textarea.value;
let rArr = [];
getRepositories();
///////////////////////////////////

function enterKey(e) {
    if (e.keyCode == 181) {
        document.location.reload(true);
    }
    if (e.keyCode == 13) {
        commands.push(command.innerHTML);
        git = commands.length;
        addLine("<span class='hostname'>guest@aminhce.dev:~$</span> " + command.innerHTML, "no-animation", 0);
        commander(command.innerHTML.toLowerCase());
        command.innerHTML = "";
        textarea.value = "";
    }
    if (e.keyCode == 38 && git != 0) {
        git -= 1;
        textarea.value = commands[git];
        command.innerHTML = textarea.value;
    }
    if (e.keyCode == 40 && git != commands.length) {
        git += 1;
        if (commands[git] === undefined) {
            textarea.value = "";
        } else {
            textarea.value = commands[git];
        }
        command.innerHTML = textarea.value;
    }
}

function commander(cmd) {
    switch (cmd.toLowerCase()) {
        case "exit":
            window.open(window.location,'_self').close();
            break;
        case "dnf":
            loopLines(dnf, "color2 margin", 80);
            break;
        case "help":
            loopLines(help, "color2 margin", 80);
            break;
        case "whois":
            loopLines(whois, "color2 margin", 80);
            break;
        case "social":
            loopLines(social, "color2 margin", 80);
            break;
        case String(cmd.match(/^project.*/i)):
            let project = cmd.split(' ').reverse()[0];
            if (project != 'project') {
                addLine('Opening Project ['+ project +'] ...', "", 0);
                newTab(github + '/' + project)
            } else {
                loopLines(rArr, "color2 margin", 80);
            }
            break;
        case "history":
            addLine("<br>", "", 0);
            loopLines(commands, "color2", 80);
            addLine("<br>", "command", 80 * commands.length + 50);
            break;
        case "resume --lang fa":
            addLine('Opening Resume [Language: Farsi] ...', "color2", 100);
            newTab(resume_fa);
            break;
        case "resume":
        case "resume --lang en":
            addLine('Opening Resume [Language: English] ...', "color2", 100);
            newTab(resume_en);
            break;
        case "resume -dl":
        case "resume -dl --lang en":
        case "resume --lang en -dl":
            addLine('Downloading Resume [Language: English] ...', "color2", 100);
            let printWindow = window.open(resume_en);
            printWindow.focus();
            printWindow.print();
            //Close window once print is finished
            printWindow.onafterprint = function(){
               printWindow.close();
            };
            break;
        case "resume -dl --lang fa":
        case "resume --lang fa -dl":
            addLine('Downloading Resume [Language: English] ...', "color2", 100);
            let printWindowFa = window.open(resume_fa);
            printWindowFa.focus();
            printWindowFa.print();
            //Close window once print is finished
            printWindowFa.onafterprint = function(){
               printWindowFa.close();
            };
            break;
        case "clear":
            setTimeout(function() {
                terminal.innerHTML = '<a id="before"></a>';
                before = document.getElementById("before");
                loopLines(banner, "", 80);

            }, 1);
            break;


        // socials
        case "twitter":
            addLine("Opening Twitter ...", "color2", 0);
            newTab(twitter);
            break;
        case "linkedin":
            addLine("Opening LinkedIn ...", "color2", 0);
            newTab(linkedin);
            break;
        case "instagram":
            addLine("Opening Instagram ...", "color2", 0);
            newTab(instagram);
            break;
        case "github":
            addLine("Opening GitHub ...", "color2", 0);
            newTab(github);
            break;

        default:
            addLine("command not found: " + cmd, "color2 margin", 75);
            addLine("<span class=\"inherit\">Command not found. For a list of commands, type <span class=\"command\">'help'</span>.</span>", "error", 1000);
            break;
    }
}

async function getRepositories() {
    let res = await axios.get('https://api.github.com/users/aminhce/repos');
    let repositories = res.data;
    let repoNameArr = [];
    let repoLinkArr = [];

    for(let i = 0; i < repositories.length; i++){
        repoNameArr.push(repositories[i].name);
        repoLinkArr.push(repositories[i].html_url);
    }
    for(let i = 0; i < repositories.length; i++){
        rArr.push('<a href="' + repoLinkArr[i] + '" target="_blank">'+ repoNameArr[i] + "</a>");
    }
}

function newTab(link) {
    setTimeout(function() {
        window.open(link, "_blank");
    }, 500);
}

function addLine(text, style, time) {
    var t = "";
    for (let i = 0; i < text.length; i++) {
        if (text.charAt(i) == " " && text.charAt(i + 1) == " ") {
            t += "&nbsp;&nbsp;";
            i++;
        } else {
            t += text.charAt(i);
        }
    }
    setTimeout(function() {
        var next = document.createElement("p");
        next.innerHTML = t;
        next.className = style;

        before.parentNode.insertBefore(next, before);

        window.scrollTo(0, document.body.offsetHeight);
    }, time);
}

function loopLines(name, style, time) {
    name.forEach(function(item, index) {
        addLine(item, style, index * time);
    });
}

function setFocus() {
    document.getElementById('texter').focus();
}
