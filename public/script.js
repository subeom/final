function list_view_handleClick(cb) {
    var xhttp = new XMLHttpRequest();
    xhttp.onreadystatechange = function() {
      if (this.readyState == 4 && this.status == 200) {
        document.getElementById("message").innerText = this.responseText;
      }
    };

    xhttp.open("POST", "/change/status", true);
    xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhttp.send("item_id=" + cb.id + "&deleted=" + cb.checked);
    alert("item_id=" + cb.id + "&deleted=" + cb.checked);
}