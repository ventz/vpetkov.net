// Ventz Changes: overlay of themes/PaperMod/assets/js/fastsearch.js.
// Additions over the theme version, all driven by fuseOpts.includeMatches:
//   1. Highlighted context snippets under each result (matched text in <mark>)
//   2. Title-match highlighting
//   3. A live status line: result count / "No results for X" (aria-live for a11y)
// Keeps the theme's li > [title, svg, .entry-link] structure intact — the empty
// overlay .entry-link anchor is focused directly by keyboard nav (see CLAUDE.md
// pitfall about .entry-link producers) — the snippet is inserted before it.
import * as params from '@params';

const resList = document.getElementById('searchResults');
const sInput = document.getElementById('searchInput');
const searchBox = document.getElementById('searchbox');

let fuse;
let currentElement = null;
let firstResult = null;
let lastResult = null;

// Ventz Changes BEGIN: live status line ("N results" / "No results"), created here so
// the theme's search.html template needs no overlay.
let statusLine = null;
const ensureStatusLine = () => {
    if (statusLine || !searchBox) {
        return;
    }
    statusLine = document.createElement('div');
    statusLine.id = 'searchStatus';
    statusLine.className = 'search-status';
    statusLine.setAttribute('role', 'status');
    statusLine.setAttribute('aria-live', 'polite');
    resList.before(statusLine);
};

const setStatus = (text) => {
    ensureStatusLine();
    if (statusLine) {
        statusLine.textContent = text;
    }
};
// Ventz Changes END

const defaultFuseOptions = {
    distance: 100,
    threshold: 0.4,
    ignoreLocation: true,
    keys: ['title', 'permalink', 'summary', 'content']
};

const buildFuseOptions = () => {
    if (!params.fuseOpts) {
        return defaultFuseOptions;
    }

    return {
        isCaseSensitive: params.fuseOpts.iscasesensitive ?? false,
        includeScore: params.fuseOpts.includescore ?? false,
        includeMatches: params.fuseOpts.includematches ?? false,
        minMatchCharLength: params.fuseOpts.minmatchcharlength ?? 1,
        shouldSort: params.fuseOpts.shouldsort ?? true,
        findAllMatches: params.fuseOpts.findallmatches ?? false,
        keys: params.fuseOpts.keys ?? defaultFuseOptions.keys,
        location: params.fuseOpts.location ?? 0,
        threshold: params.fuseOpts.threshold ?? defaultFuseOptions.threshold,
        distance: params.fuseOpts.distance ?? defaultFuseOptions.distance,
        ignoreLocation: params.fuseOpts.ignorelocation ?? defaultFuseOptions.ignoreLocation
    };
};

const debounce = (fn, delay) => {
    let timeout;
    return (...args) => {
        clearTimeout(timeout);
        timeout = window.setTimeout(() => fn(...args), delay);
    };
};

const reset = () => {
    currentElement = null;
    firstResult = null;
    lastResult = null;
    resList.innerHTML = '';
    setStatus(''); // Ventz Changes: clear the status line along with the results
    sInput.value = '';
    sInput.focus();
};

const setActiveResult = (element) => {
    document.querySelectorAll('.focus').forEach((item) => item.classList.remove('focus'));

    if (!element) {
        return;
    }

    element.focus();
    element.parentElement?.classList.add('focus');
    currentElement = element;
};

// Ventz Changes BEGIN: highlight helpers. Fuse match indices are inclusive [from, to]
// pairs into the ORIGINAL string; window [start, end) clips them for snippets.
// DOM is built from text nodes + <mark> elements — post content never touches innerHTML.
const highlightedFragment = (text, indices, start, end) => {
    const fragment = document.createDocumentFragment();
    let cursor = start;

    for (const [from, to] of indices) {
        const markFrom = Math.max(from, start);
        const markTo = Math.min(to + 1, end);
        if (markTo <= cursor || markFrom >= end) {
            continue;
        }
        if (markFrom > cursor) {
            fragment.appendChild(document.createTextNode(text.slice(cursor, markFrom)));
        }
        const mark = document.createElement('mark');
        mark.textContent = text.slice(Math.max(markFrom, cursor), markTo);
        fragment.appendChild(mark);
        cursor = markTo;
    }

    if (cursor < end) {
        fragment.appendChild(document.createTextNode(text.slice(cursor, end)));
    }

    return fragment;
};

const longestIndexPair = (indices) =>
    indices.reduce((best, pair) => (pair[1] - pair[0] > best[1] - best[0] ? pair : best));

// Ventz Changes (cont.): build the context snippet for one result — prefers a body/summary
// match; falls back to a matched tag so tag-only hits still explain themselves.
const SNIPPET_BEFORE = 50;
const SNIPPET_LENGTH = 160;

const buildSnippet = (result) => {
    const matches = result.matches ?? [];
    const textMatch =
        matches.find((m) => m.key === 'content') ?? matches.find((m) => m.key === 'summary');

    if (textMatch) {
        const text = textMatch.value ?? '';
        const [primaryStart] = longestIndexPair(textMatch.indices);
        let start = Math.max(0, primaryStart - SNIPPET_BEFORE);
        // snap forward to a word boundary so snippets don't open mid-word
        if (start > 0) {
            const nextSpace = text.indexOf(' ', start);
            if (nextSpace !== -1 && nextSpace < primaryStart) {
                start = nextSpace + 1;
            }
        }
        const end = Math.min(text.length, start + SNIPPET_LENGTH);

        const snippet = document.createElement('p');
        snippet.className = 'search-snippet';
        if (start > 0) {
            snippet.appendChild(document.createTextNode('…'));
        }
        snippet.appendChild(highlightedFragment(text, textMatch.indices, start, end));
        if (end < text.length) {
            snippet.appendChild(document.createTextNode('…'));
        }
        return snippet;
    }

    const tagMatch = matches.find((m) => m.key === 'tags');
    if (tagMatch) {
        const snippet = document.createElement('p');
        snippet.className = 'search-snippet';
        snippet.appendChild(document.createTextNode('Tagged: '));
        snippet.appendChild(
            highlightedFragment(tagMatch.value ?? '', tagMatch.indices, 0, (tagMatch.value ?? '').length)
        );
        return snippet;
    }

    return null;
};
// Ventz Changes END

const renderResults = (results) => {
    if (!Array.isArray(results) || results.length === 0) {
        resList.innerHTML = '';
        firstResult = lastResult = currentElement = null;
        return;
    }

    const fragment = document.createDocumentFragment();

    for (const result of results) {
        const li = document.createElement('li');

        // Ventz Changes BEGIN: title is a span (was a bare text node) so title matches highlight
        const title = document.createElement('span');
        title.className = 'search-title';
        const titleMatch = (result.matches ?? []).find((m) => m.key === 'title');
        if (titleMatch) {
            title.appendChild(
                highlightedFragment(result.item.title, titleMatch.indices, 0, result.item.title.length)
            );
        } else {
            title.textContent = result.item.title;
        }
        // Ventz Changes END

        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.setAttribute('width', '24');
        svg.setAttribute('height', '24');
        svg.setAttribute('viewBox', '0 0 24 24');
        svg.setAttribute('fill', 'none');
        svg.setAttribute('stroke', 'currentColor');
        svg.setAttribute('stroke-width', '2');
        svg.setAttribute('stroke-linecap', 'round');
        svg.setAttribute('stroke-linejoin', 'round');
        svg.classList.add('feather', 'feather-chevrons-right');

        svg.innerHTML = '<polyline points="13 17 18 12 13 7"></polyline><polyline points="6 17 11 12 6 7"></polyline>';

        const link = document.createElement('a');
        link.className = 'entry-link';
        link.href = result.item.permalink;
        link.setAttribute('aria-label', result.item.title);

        li.appendChild(title);
        li.appendChild(svg);
        // Ventz Changes BEGIN: context snippet with highlighted match
        const snippet = buildSnippet(result);
        if (snippet) {
            li.appendChild(snippet);
        }
        // Ventz Changes END
        li.appendChild(link);
        fragment.appendChild(li);
    }

    resList.innerHTML = '';
    resList.appendChild(fragment);
    firstResult = resList.firstElementChild;
    lastResult = resList.lastElementChild;
};

const performSearch = () => {
    if (!fuse) {
        return;
    }

    const query = sInput.value.trim();
    if (!query) {
        renderResults([]);
        setStatus(''); // Ventz Changes: empty query clears the status line too
        return;
    }

    const searchOptions = params.fuseOpts?.limit ? { limit: params.fuseOpts.limit } : undefined;
    const results = searchOptions ? fuse.search(query, searchOptions) : fuse.search(query);
    renderResults(results);

    // Ventz Changes BEGIN: result count / no-results feedback
    if (results.length === 0) {
        setStatus(`No results for “${query}”`);
    } else {
        setStatus(`${results.length} result${results.length === 1 ? '' : 's'}`);
    }
    // Ventz Changes END
};

const initSearch = async () => {
    if (!sInput || !resList) {
        return;
    }

    sInput.disabled = false;
    sInput.focus();

    try {
        const response = await fetch('../index.json');
        if (!response.ok) {
            throw new Error(`Search index load failed: ${response.status}`);
        }

        const data = await response.json();
        if (data) {
            fuse = new Fuse(data, buildFuseOptions());
        }
    } catch (error) {
        console.error(error);
    }
};

window.addEventListener('load', initSearch);

sInput?.addEventListener('input', debounce(performSearch, 150));

sInput?.addEventListener('search', () => {
    if (!sInput.value) {
        reset();
    }
});

document.addEventListener('keydown', (event) => {
    const { key } = event;
    const active = document.activeElement;
    const isInSearchBox = searchBox?.contains(active);

    if (key === 'Escape') {
        reset();
        return;
    }

    if (!firstResult || !isInSearchBox) {
        return;
    }

    if (key === 'ArrowDown') {
        event.preventDefault();

        if (active === sInput) {
            setActiveResult(firstResult.querySelector('.entry-link'));
        } else if (active?.parentElement !== lastResult) {
            setActiveResult(active?.parentElement?.nextElementSibling?.querySelector('.entry-link'));
        }
    } else if (key === 'ArrowUp') {
        event.preventDefault();

        if (active?.parentElement === firstResult) {
            setActiveResult(sInput);
        } else if (active !== sInput) {
            setActiveResult(active?.parentElement?.previousElementSibling?.querySelector('.entry-link'));
        }
    } else if (key === 'ArrowRight') {
        if (active?.matches?.('.entry-link')) {
            active.click();
        }
    }
});
