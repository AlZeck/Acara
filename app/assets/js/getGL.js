function redirectGL(geolog) {
    str = `gl=${Math.round(geolog.coords.latitude * 100000) / 100000},${Math.round(geolog.coords.longitude * 100000) / 100000}`;

    if(location.href.includes("?"))
        str = "&" + str
    else
        str = "?" + str

    location.href+=str;
}

if( document.getElementsByClassName("alert").length == 0 )
    navigator.geolocation.getCurrentPosition(redirectGL);