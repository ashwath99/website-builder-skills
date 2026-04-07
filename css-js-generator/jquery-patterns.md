# jQuery Interaction Patterns, Animation & Code Quality

→ This file is a reference for css-js-generator/SKILL.md

---

## 7 — jQuery Interaction Patterns

All JS uses jQuery. No other libraries. Wrapped in a ready handler.

### 7.1 — File Structure

```javascript
$(document).ready(function() {
  // Tab functionality
  initTabs();

  // Accordion functionality
  initAccordion();

  // Scroll-triggered behaviors
  initScrollEffects();

  // Sticky bar
  initStickyBar();
});
```

### 7.2 — Tab Switcher

```javascript
function initTabs() {
  $('.{product}-tab-panel__tab').on('click', function() {
    var $this = $(this);
    var targetPanel = $this.attr('aria-controls');

    // Update tab states
    $this.closest('.{product}-tab-panel__tabs')
      .find('.{product}-tab-panel__tab')
      .removeClass('{product}-tab-panel__tab--active')
      .attr('aria-selected', 'false');
    $this.addClass('{product}-tab-panel__tab--active')
      .attr('aria-selected', 'true');

    // Update panel visibility
    $this.closest('.{product}-tab-panel')
      .find('.{product}-tab-panel__panel')
      .removeClass('{product}-tab-panel__panel--active');
    $('#' + targetPanel).addClass('{product}-tab-panel__panel--active');
  });
}
```

### 7.3 — Accordion Toggle

```javascript
function initAccordion() {
  $('.{product}-accordion__trigger').on('click', function() {
    var $item = $(this).closest('.{product}-accordion__item');
    var isOpen = $item.hasClass('{product}-accordion__item--open');

    // Close all items (single-open mode)
    $item.closest('.{product}-accordion__items')
      .find('.{product}-accordion__item')
      .removeClass('{product}-accordion__item--open')
      .find('.{product}-accordion__trigger')
      .attr('aria-expanded', 'false');

    // Open clicked item (if it was closed)
    if (!isOpen) {
      $item.addClass('{product}-accordion__item--open');
      $(this).attr('aria-expanded', 'true');
    }
  });
}
```

### 7.4 — Scroll-Triggered Animations

```javascript
function initScrollEffects() {
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        $(entry.target).addClass('{product}-animate--visible');
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15 });

  $('.{product}-animate').each(function() {
    observer.observe(this);
  });
}
```

**CSS for scroll animations:**
```css
.{product}-animate {
  opacity: 0;
  transform: translateY(30px);
  transition: opacity 0.6s ease-out, transform 0.6s ease-out;
}
.{product}-animate--visible {
  opacity: 1;
  transform: translateY(0);
}
```

### 7.5 — Sticky CTA Bar

```javascript
function initStickyBar() {
  var $stickyBar = $('.{product}-sticky-bar');
  if (!$stickyBar.length) return;

  var heroBottom = $('.{product}-hero').offset().top + $('.{product}-hero').outerHeight();

  $(window).on('scroll', function() {
    if ($(window).scrollTop() > heroBottom) {
      $stickyBar.addClass('{product}-sticky-bar--visible');
    } else {
      $stickyBar.removeClass('{product}-sticky-bar--visible');
    }
  });
}
```

### 7.6 — Animated Metrics Counter

```javascript
function initCounters() {
  var observer = new IntersectionObserver(function(entries) {
    entries.forEach(function(entry) {
      if (entry.isIntersecting) {
        var $el = $(entry.target);
        var target = parseInt($el.data('count'), 10);
        $({ count: 0 }).animate({ count: target }, {
          duration: 1500,
          easing: 'swing',
          step: function() {
            $el.text(Math.floor(this.count).toLocaleString());
          },
          complete: function() {
            $el.text(target.toLocaleString());
          }
        });
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.5 });

  $('.{product}-metrics-bar__value[data-count]').each(function() {
    observer.observe(this);
  });
}
```

---

## 8 — Animation & Transition Standards

| Property | Standard Value |
|---|---|
| Default transition duration | `0.3s` |
| Scroll animation duration | `0.6s` |
| Easing function (UI) | `ease-in-out` |
| Easing function (scroll) | `ease-out` |
| Hover transitions | `transition: {property} 0.3s ease-in-out` |
| No animation on page load | Animations only trigger on scroll or interaction |

**Rule:** Never use `transition: all`. Always specify the exact property being transitioned.

---

## 9 — Code Quality Rules

| Rule | Detail |
|---|---|
| No `!important` | Unless absolutely necessary — document with comment explaining why |
| No inline styles | All styles in `styles.css` |
| No inline scripts | All JS in `script.js` |
| No hardcoded values in rulesets | Everything references `var(--{product}-*)` |
| No ID selectors for styling | IDs are for JS hooks and anchor links only |
| No vendor prefixes manually | Unless targeting a specific known issue (documented with comment) |
| No `float` for layout | Use flexbox or grid |
| No `@import` in CSS | Single file, no imports |
| jQuery version | 3.7.x (latest stable 3.x) |
| No other JS libraries | jQuery only — no Slick, no GSAP, no other plugins |
