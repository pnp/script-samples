document.addEventListener('DOMContentLoaded', function () {
  var sampleListing = document.getElementById('sample-listing');
  if (!sampleListing) return;

  var filterText = sampleListing.getAttribute('data-filter');
  var qsRegex;
  var buttonFilter;
  var viewMode = sampleListing.getAttribute('data-view') || 'grid'; // Default view mode

  // Check if Isotope is available
  if (typeof Isotope === 'undefined') {
    console.error('Isotope library is not loaded');
    return;
  }

  // init Isotope
  var grid = new Isotope('#sample-listing', {
    itemSelector: '.sample-thumbnail',
    layoutMode: 'fitRows',
    sortBy: 'modified',
    sortAscending: false,
    getSortData: {
      modified: '[data-modified]',
      title: '.sample-title'
    },
    filter: function (itemElem) {
      var keywords = itemElem.getAttribute('data-keywords');
      var searchResult = qsRegex ? keywords.match(qsRegex) : true;
      var buttonResult = buttonFilter ? itemElem.matches(buttonFilter) : true;
      return searchResult && buttonResult;
    },
    fitRows: {
      columnWidth: '.grid-sizer'
    }
  });

  // Display/hide a message when there are no results
  grid.on('arrangeComplete', function (filteredItems) {
    var noResults = document.getElementById('noresults');
    if (noResults) {
      if (filteredItems.length > 0) {
        noResults.style.display = 'none';
      } else {
        noResults.style.display = 'block';
      }
    }
  });

  // Get the JSON
  fetch(jsonPath)
    .then(response => response.json())
    .then(data => {
      var asc = true;
      var prop = "updateDateTime";

      // Sort data descending order
      data = data.sort(function (a, b) {
        try {
          if (asc) return (a[prop] > b[prop]) ? 1 : ((a[prop] < b[prop]) ? -1 : 0);
          else return (b[prop] > a[prop]) ? 1 : ((b[prop] < a[prop]) ? -1 : 0);
        } catch (error) {
          return 0;
        }
      });

      data.forEach(function (sample) {
        var item = loadSample(sample, filterText, viewMode);
        if (item !== null) {
          var tempDiv = document.createElement('div');
          tempDiv.innerHTML = item;
          var element = tempDiv.firstElementChild;
          sampleListing.appendChild(element);
          grid.appended(element);
        }
      });

      // Update the sort
      grid.updateSortData();
      grid.arrange();
    })
    .catch(error => console.error('Error loading samples:', error));

  // Get the list of filters to use
  var filterChoices = document.querySelectorAll('#filters .filter-choice');

  // Get the search box
  var searchInput = document.getElementById('post-search-input');

  var filterLists = document.querySelectorAll('.filter-list');
  filterLists.forEach(function (buttonGroup) {
    buttonGroup.addEventListener('click', function (event) {
      var target = event.target;
      if (target.classList.contains('filter-choice')) {
        var activeInGroup = buttonGroup.querySelector('.active');
        if (activeInGroup) {
          activeInGroup.classList.remove('active');
        }
        target.classList.add('active');
        
        var filters = [];
        var activeFilters = document.querySelectorAll('#filters .filter-choice.active');
        activeFilters.forEach(function (filter) {
          filters.push(filter.getAttribute('data-filter'));
        });

        filters = filters.join('');
        buttonFilter = filters;
        grid.arrange();
      }
    });
  });

  if (searchInput) {
    // Create a single function for search handling
    function handleSearch() {
      qsRegex = new RegExp(searchInput.value, 'gi');
      grid.arrange();

      // Update the URL
      var url = window.location.href;
      var urlParts = url.split("?");
      var searchVal = searchInput.value;
      var newUrl = urlParts[0];

      if (searchVal.length > 0) {
        newUrl = urlParts[0] + "?query=" + searchVal;
      }

      window.history.pushState({}, "", newUrl);
    }

    // Attach the handler to all relevant events
    searchInput.addEventListener('input', debounce(handleSearch, 200));
    searchInput.addEventListener('keyup', debounce(handleSearch, 200));
    searchInput.addEventListener('paste', debounce(handleSearch, 200));
  }

  // debounce so filtering doesn't happen every millisecond
  function debounce(fn, threshold) {
    var timeout;
    return function debounced() {
      if (timeout) {
        clearTimeout(timeout);
      }
      function delayed() {
        fn();
        timeout = null;
      }
      timeout = setTimeout(delayed, threshold || 100);
    };
  }

  // See if there are any passed parameters
  try {
    grid.once('arrangeComplete', function () {
      var urlParams = new URLSearchParams(window.location.search);
      var query = urlParams.get('query');
      if (query !== "" && query !== null && searchInput) {
        searchInput.value = query;
        searchInput.dispatchEvent(new Event('input'));
      }
    });
  } catch (error) {
    // Be vewy vewy quiet
  }
});