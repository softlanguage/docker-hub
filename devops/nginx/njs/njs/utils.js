// https://github.com/liuxuc63/njs-examples
function version(r) {
    r.return(200, njs.version);
}
function prefixOfUri(r) {
    var pass = r.uri;
    var pp = "";
    if (pass.length > 1 && pass.charAt(0) == '/') {
        pp = pass.split("/", 2)[1].split("?", 1);
    }
    return pp;
}
export default {version, prefixOfUri}