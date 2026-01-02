WINDOW_CONTENTS = window.location.href.split('/')
SELECTED_LANGUAGE = 'dotnet'
ATTR1 = '[<span class="hljs-meta">System.ComponentModel.EditorBrowsable</span>]\n<'

// Navbar Hamburger
document.addEventListener('DOMContentLoaded', function () {
    var navbarToggle = document.querySelector(".navbar-toggle");
    if (navbarToggle) {
        navbarToggle.addEventListener('click', function () {
            this.classList.toggle("change");
        });
    }
});

// Select list to replace affix on small screens
document.addEventListener('DOMContentLoaded', function () {
    var navItems = document.querySelectorAll(".sideaffix .level1 > li");

    if (navItems.length === 0) {
        return;
    }

    var selector = document.createElement("select");
    selector.className = "form-control visible-sm visible-xs";
    var form = document.createElement("form");
    form.appendChild(selector);
    
    var article = document.querySelector("article");
    if (article) {
        article.insertBefore(form, article.firstChild);
    }

    selector.addEventListener('change', function () {
        var selected = this.options[this.selectedIndex];
        if (selected) {
            window.location = selected.value;
        }
    });

    function work(item, level) {
        var link = item.querySelector('a');
        if (!link) return;

        var text = link.textContent;

        for (var i = 0; i < level; ++i) {
            text = '&nbsp;&nbsp;' + text;
        }

        var option = document.createElement('option');
        option.value = link.getAttribute('href');
        option.innerHTML = text;
        selector.appendChild(option);

        var nested = item.querySelector('ul');

        if (nested) {
            var nestedItems = nested.querySelectorAll(':scope > li');
            nestedItems.forEach(function (nestedItem) {
                work(nestedItem, level + 1);
            });
        }
    }

    navItems.forEach(function (item) {
        work(item, 0);
    });
});


document.addEventListener('DOMContentLoaded', function () {
    
    // Add text to empty links
    var emptyLinks = document.querySelectorAll("p > a");
    emptyLinks.forEach(function (linkEl) {
        var link = linkEl.getAttribute('href');
        if (linkEl.textContent === "") {
            linkEl.innerHTML = link;
        }
    });

    // Remove export html wrapper from bash tab
    var bashCode = document.querySelectorAll("code.lang-bash");
    bashCode.forEach(function (codeEl) {
        var text = codeEl.innerHTML;
        text = text.replace(/<span class="hljs-built_in">export.*<\/span>/, "export");
        codeEl.innerHTML = text;
    });
});
    

// For the demos section that is generated at runtime, 
// fix for the pencil referencing section that does not yet exist
document.addEventListener('DOMContentLoaded', function (){
    var improveDocLinks = document.querySelectorAll("a.improve-doc-lg");
    improveDocLinks.forEach(function (linkEl) {
        var link = linkEl.getAttribute('href');
        if(link && link.indexOf("/dev/docs/demos/") > -1){
            link = link.replace("/dev/docs/demos/","/dev/samples/");
            linkEl.setAttribute('href', link);
        }
    });
});


// Copy to clipboard
document.addEventListener('DOMContentLoaded', function (){
    if (typeof ClipboardJS !== 'undefined') {
        var clipboard = new ClipboardJS('button.article-clipboard');
        clipboard.on('success', function(e) {
            e.clearSelection();

            var message = e.trigger.querySelector('span.article-clipboard__message');
            if (message) {
                message.classList.add('copied');
                setTimeout(function(){
                    message.classList.remove('copied');
                }, 600);
            }
        });
    }
});

// Command Help
function getSiteBaseAddress(){

    var baseSiteAddress = (document.location.host === "pnp.github.io") ?  
        document.location.origin + "/script-samples" : document.location.origin;

    return baseSiteAddress;
}

document.addEventListener('DOMContentLoaded', function (){

    //if tabs, if tabs contain m365 load JSON file, if tabs contain -PnP load file
    if(document.querySelector("a[data-tab='cli-m365-ps']") || document.querySelector("a[data-tab='m365cli-bash']")){
       
        var jsonHelpPath = getSiteBaseAddress() +"/assets/help/cli.help.json";
      
        // Load inline help
        fetch(jsonHelpPath)
            .then(response => response.json())
            .then(data => {
                data.forEach(function (helpItem) {
                    var cmdlet = helpItem.cmd;
                    var cmdHelpUrl = helpItem.helpUrl;
                    var tabs = ["cli-m365-ps","m365cli-bash","cli-m365-bash"]; //TODO: this needs fixing

                    updateCmdletWithHelpLinks(tabs, cmdlet, cmdHelpUrl);   
                });
            })
            .catch(error => console.error('Error loading CLI help:', error));
    }

    if(document.querySelector("a[data-tab='pnpps']")){
        var jsonHelpPath = getSiteBaseAddress() +"/assets/help/powershell.help.json";
        fetch(jsonHelpPath)
            .then(response => response.json())
            .then(data => {
                data.forEach(function (helpItem) {
                    var cmdlet = helpItem.cmd;
                    var cmdHelpUrl = helpItem.helpUrl;
                    var tabs = ["pnpps"]; //TODO: this needs fixing

                    updateCmdletWithHelpLinksPs(tabs, cmdlet, cmdHelpUrl);                
                });
            })
            .catch(error => console.error('Error loading PowerShell help:', error));
    }

    if(document.querySelector("a[data-tab='spoms-ps']")){
        var jsonHelpPath = getSiteBaseAddress() +"/assets/help/spoms.help.json";
        fetch(jsonHelpPath)
            .then(response => response.json())
            .then(data => {
                data.forEach(function (helpItem) {
                    var cmdlet = helpItem.cmd;
                    var cmdHelpUrl = helpItem.helpUrl;
                    var tabs = ["spoms-ps"]; //TODO: this needs fixing

                    updateCmdletWithHelpLinksPs(tabs, cmdlet, cmdHelpUrl);                 
                });
            })
            .catch(error => console.error('Error loading SPOMS help:', error));
    }

    function updateCmdletWithHelpLinksPs(tabs, cmdlet, cmdHelpUrl) {

        tabs.forEach(function (tab) {
            var codeElements = document.querySelectorAll("section[data-tab='" + tab + "'] pre code");
            codeElements.forEach(function (codeEl) {
                var lines = Array.from(codeEl.childNodes);
                lines.forEach(function (line) {
                    if (line.nodeType === Node.TEXT_NODE || line.nodeType === Node.ELEMENT_NODE) {
                        var text = line.textContent;
                        
                        if (text.includes(cmdlet)) {
                            var parts = text.split(" ");
                            var updatedParts = parts.map(part => {
                                var partClean = part.replace(/\n/g, "");
                                return partClean === cmdlet ? `<a href='${cmdHelpUrl}' class='cmd-help' target='_blank'>${part}</a>` : part;
                            });
                        
                            if (parts.toString() !== updatedParts.toString()) {
                                var newContent = document.createRange().createContextualFragment(updatedParts.join(" "));
                                line.replaceWith(newContent);
                            }
                        }
                    }
                });
            });
        });
    }

    function updateCmdletWithHelpLinks(tabs, cmdlet, cmdHelpUrl) {

        tabs.forEach(function (tab) {
            var codeElements = document.querySelectorAll("section[data-tab='" + tab + "'] pre code");
            codeElements.forEach(function (codeEl) {
                var lines = Array.from(codeEl.childNodes);
                lines.forEach(function (line) {
                    if (line.nodeType === Node.TEXT_NODE || line.nodeType === Node.ELEMENT_NODE) {
                        var text = line.textContent;
                        if (text.indexOf(cmdlet) > -1) {
                            var parts = text.split(cmdlet);
                            var newContent = document.createRange().createContextualFragment(
                                parts[0] + "<a href='" + cmdHelpUrl + "' class='cmd-help' target='_blank'>" + cmdlet + "</a>" + parts[1]
                            );
                            line.replaceWith(newContent);
                        }
                    }
                });
            });
        });
    }
});

// Function to get the repositories statistics in GitHub
// Fetch GitHub repository facts
document.addEventListener('DOMContentLoaded', function () {
    var repoName = "pnp/script-samples";
    var url = "https://api.github.com/repos/" + repoName;
    var repoStats = {
        "forks": 0,
        "stars": 0,
        "watchers": 0
    };

    fetch(url)
        .then(response => response.json())
        .then(data => {
            repoStats.forks = data.forks_count;
            repoStats.stars = data.stargazers_count;
            repoStats.watchers = data.subscribers_count;

            // Update the stats
            var forksEl = document.querySelector(".github-forks");
            var starsEl = document.querySelector(".github-stars");
            var watchersEl = document.querySelector(".github-watchers");
            
            if (forksEl) forksEl.textContent = repoStats.forks;
            if (starsEl) starsEl.textContent = repoStats.stars;
            if (watchersEl) watchersEl.textContent = repoStats.watchers;
        })
        .catch(error => console.error('Error fetching GitHub stats:', error));
});
