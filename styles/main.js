// Use container fluid
// var containers = $(".container");
// containers.removeClass("container");
// containers.addClass("container-fluid");

WINDOW_CONTENTS = window.location.href.split('/')
SELECTED_LANGUAGE = 'dotnet'
BLOB_URI_PREFIX = 'https://azuresdkdocs.blob.core.windows.net/$web/dotnet/'

ATTR1 = '[<span class="hljs-meta">System.ComponentModel.EditorBrowsable</span>]\n<'

// Navbar Hamburger
$(function () {
    $(".navbar-toggle").click(function () {
        $(this).toggleClass("change");
    })
})

// Select list to replace affix on small screens
$(function () {
    var navItems = $(".sideaffix .level1 > li");

    if (navItems.length == 0) {
        return;
    }

    var selector = $("<select/>");
    selector.addClass("form-control visible-sm visible-xs");
    var form = $("<form/>");
    form.append(selector);
    form.prependTo("article");

    selector.change(function () {
        window.location = $(this).find("option:selected").val();
    })

    function work(item, level) {
        var link = item.children('a');

        var text = link.text();

        for (var i = 0; i < level; ++i) {
            text = '&nbsp;&nbsp;' + text;
        }

        selector.append($('<option/>', {
            'value': link.attr('href'),
            'html': text
        }));

        var nested = item.children('ul');

        if (nested.length > 0) {
            nested.children('li').each(function () {
                work($(this), level + 1);
            });
        }
    }

    navItems.each(function () {
        work($(this), 0);
    });
})


$(function () {
    // Inject line breaks and spaces into the code sections
    //$(".lang-csharp").each(function () {
    //    var text = $(this).html();
    //    text = text.replace(/, /g, ",</br>&#09;&#09");
    //    text = text.replace(ATTR1, '<');
    //    $(this).html(text);
    //});

    // Add text to empty links
    $("p > a").each(function () {
        var link = $(this).attr('href')
        if ($(this).text() === "") {
            $(this).html(link)
        }
    });

    // Remove export html wrapper from bash tab
    $("code.lang-bash").each(function () {
        var text = $(this).html();
        text = text.replace(/<span class="hljs-built_in">export.*<\/span>/, "export");
        $(this).html(text);
    });
});
    
function httpGetAsync(targetUrl, callback) {
    var xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = function () {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
            callback(xmlHttp.responseText);
    }
    xmlHttp.open("GET", targetUrl, true); // true for asynchronous 
    xmlHttp.send(null);
}

function populateOptions(selector, packageName) {
    var versionRequestUrl = BLOB_URI_PREFIX + packageName + "/versioning/versions"

    httpGetAsync(versionRequestUrl, function (responseText) {
        var versionselector = document.createElement("select")
        var cv = WINDOW_CONTENTS[6]

        versionselector.className = 'navbar-version-select'
        if (responseText) {
            options = responseText.match(/[^\r\n]+/g)
            for (var i in options) {
                $(versionselector).append('<option value="' + options[i] + '">' + options[i] + '</option>')
            }
        }

        if(cv === 'latest')
        {
            $(versionselector).selectedIndex = 0
        }
        else {
            $(versionselector).val(cv);
        }
        
        $(selector).append(versionselector)

        $(versionselector).change(function () {
            targetVersion = $(this).val()
            url = WINDOW_CONTENTS.slice()
            url[6] = targetVersion
            window.location.href = url.join('/')
        });

    })
}


function populateIndexList(selector, packageName) {
    url = BLOB_URI_PREFIX + packageName + "/versioning/versions"

    httpGetAsync(url, function (responseText) {

        var publishedversions = document.createElement("ul")
        if (responseText) {
            options = responseText.match(/[^\r\n]+/g)

            for (var i in options) {
                $(publishedversions).append('<li><a href="' + getPackageUrl(SELECTED_LANGUAGE, packageName, options[i]) + '" target="_blank">' + options[i] + '</a></li>')
            }
        }
        else {
            $(publishedversions).append('<li>No discovered versions present in blob storage.</li>')
        }
        $(selector).after(publishedversions)
    })
}

function getPackageUrl(language, package, version) {
    return "https://azuresdkdocs.blob.core.windows.net/$web/" + language + "/" + package + "/" + version + "/api/index.html"
}

// Populate Versions
$(function () {
    if (WINDOW_CONTENTS.length < 7 && WINDOW_CONTENTS[WINDOW_CONTENTS.length - 1] != 'index.html') {
        console.log("Run PopulateList")

        $('h4').each(function () {
            var pkgName = $(this).text()
            populateIndexList($(this), pkgName)
        })
    }

    if (WINDOW_CONTENTS.length > 7) {
        var pkgName = WINDOW_CONTENTS[5]
        populateOptions($('#navbar'), pkgName)
    }
})

// For the demos section that is generated at runtime, 
// fix for the pencil referencing section that does not yet exist
$(function (){
    $("a.improve-doc-lg").each(function () {
        var link = $(this).attr('href');
        if(link.indexOf("/dev/docs/demos/") > -1){
            link = link.replace("/dev/docs/demos/","/dev/samples/");
            $(this).attr('href', link);
        }
    });
});


// Copy to clipboard
$(function (){
    var clipboard = new ClipboardJS('button.article-clipboard');
    clipboard.on('success', function(e) {
        e.clearSelection();

        $(e.trigger).children('span.article-clipboard__message').addClass('copied');
        var tempCopiedNotify = setInterval( function(){
            $(e.trigger).children('span.article-clipboard__message').removeClass('copied');
            clearInterval(tempCopiedNotify);
          }, 600 );
    });
});

// Command Help
function getSiteBaseAddress(){

    var baseSiteAddress = (document.location.host === "pnp.github.io") ?  
        document.location.origin + "/script-samples" : document.location.origin;

    return baseSiteAddress;
}

$(function (){

    //if tabs, if tabs contain m365 load JSON file, if tabs contain -PnP load file
    if($("a[data-tab='cli-m365-ps']") || $("a[data-tab='m365cli-bash']")){
       
        var jsonHelpPath = getSiteBaseAddress() +"/assets/help/cli.help.json";
      
        // Load inline help
        $.getJSON(jsonHelpPath, function (data) {
        
            $.each(data, function (_u, helpItem) {
        
                //Working
                var cmdlet = helpItem.cmd;
                var cmdHelpUrl = helpItem.helpUrl;
                var tabs = ["cli-m365-ps","m365cli-bash","cli-m365-bash"]; //TODO: this needs fixing

                updateCmdletWithHelpLinks(tabs, cmdlet, cmdHelpUrl);   
            });
        });
    }

    if($("a[data-tab='pnpps']")){
        var jsonHelpPath = getSiteBaseAddress() +"/assets/help/powershell.help.json";
        $.getJSON(jsonHelpPath, function (data) {
            $.each(data, function (_u, helpItem) {
                var cmdlet = helpItem.cmd;
                var cmdHelpUrl = helpItem.helpUrl;
                var tabs = ["pnpps"]; //TODO: this needs fixing

                updateCmdletWithHelpLinksPs(tabs, cmdlet, cmdHelpUrl);                
            });
        });
    }

    if($("a[data-tab='spoms-ps']")){
        var jsonHelpPath = getSiteBaseAddress() +"/assets/help/spoms.help.json";
        $.getJSON(jsonHelpPath, function (data) {
            $.each(data, function (_u, helpItem) {
                var cmdlet = helpItem.cmd;
                var cmdHelpUrl = helpItem.helpUrl;
                var tabs = ["spoms-ps"]; //TODO: this needs fixing

                updateCmdletWithHelpLinksPs(tabs, cmdlet, cmdHelpUrl);                 
            });
        });
    }

    function updateCmdletWithHelpLinksPs(tabs, cmdlet, cmdHelpUrl) {

        $.each(tabs, function (_i, tab) {
            $("section[data-tab='" + tab + "'] pre code").contents().each(function (index, line) {
                var objLine = $(line);
                    
                if (objLine.text().indexOf(cmdlet) > -1) {
                    var parts = objLine.text().split(" ");
                    var updateLine = false;
                    $.each(parts, function (_j, part) {

                        var partClean = part.replace("\n", "").replace("\n\n","");

                        //if (part === cmdlet || part === "\n" + cmdlet || part === "\n\n" + cmdlet || part ===  cmdlet + "\n" || part === "\n\n" + cmdlet) {
                        if (partClean === cmdlet) {
                            parts[_j] = part.replace(partClean, "<a href='" + cmdHelpUrl + "' class='cmd-help' target='_blank'>" + part +"</a>");
                            updateLine = true;
                        }
                    });

                    //objLine.replaceWith(parts[0] + "<a href='" + cmdHelpUrl + "' class='cmd-help' target='_blank'>" + cmdlet + "</a>" + parts[1]);
                    if(updateLine){
                        objLine.replaceWith(parts.join(" "));
                    }
                    
                }
            });
        });
    }

    function updateCmdletWithHelpLinks(tabs, cmdlet, cmdHelpUrl) {

        $.each(tabs, function (_i, tab) {
            $("section[data-tab='" + tab + "'] pre code").contents().each(function (index, line) {
                var objLine = $(line);
                    
                if (objLine.text().indexOf(cmdlet) > -1) {
                    var parts = objLine.text().split(cmdlet);
                    objLine.replaceWith(parts[0] + "<a href='" + cmdHelpUrl + "' class='cmd-help' target='_blank'>" + cmdlet + "</a>" + parts[1]);
                }
            });
        });
    }
});

// Function to get the repositories statistics in GitHub
// Fetch GitHub repository facts
$(function () {
    var repoName = "pnp/script-samples";
    var url = "https://api.github.com/repos/" + repoName;
    var repoStats = {
        "forks": 0,
        "stars": 0,
        "watchers": 0
    };

    $.getJSON(url, function (data) {
        repoStats.forks = data.forks_count;
        repoStats.stars = data.stargazers_count;
        repoStats.watchers = data.subscribers_count;

        // Update the stats
        $(".github-forks").text(repoStats.forks);
        $(".github-stars").text(repoStats.stars);
        $(".github-watchers").text(repoStats.watchers);
    });
});
