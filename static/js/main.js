
function showLoading() {
  var loadingView = _.template($('#loading-rpm-files-template').html())
  $('#content').html(loadingView())
}

function showList(json) {
  var files = json.builds.Contents

  var listView = _.template($('#rpm-file-list').html())

  var listNode = $(listView())

  var ulNode = $('<ul/>')

  for (var i=0; i<files.length; i++) {

    var itemNode = $(_.template($('#rpm_file_item_template').html())({
      fileName: files[i].Key
    }))

    ulNode.append(itemNode)
  }
  listNode.append(ulNode)

  $('#content').html(listNode)
}

$(function() {
  showLoading()

  $.getJSON('/builds/rpm').then(showList)
})

