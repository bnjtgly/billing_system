// app/javascript/controllers/patient_lookup_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "hidden", "list"];
  static values = { initialId: Number, initialLabel: String, url: String, min: { type: Number, default: 2 }, delay: { type: Number, default: 300 } };

  connect() {
    this._timer = null;
    // Prefill if provided
    if (this.initialIdValue && this.initialLabelValue && this.hasInputTarget && this.hasHiddenTarget) {
      this.inputTarget.value = this.initialLabelValue;
      this.hiddenTarget.value = this.initialIdValue;
    }
  }

  onInput(e) {
    const q = this.inputTarget.value.trim();
    if (q.length < this.minValue) {
      this.renderList([]);
      return;
    }
    if (this._timer) clearTimeout(this._timer);
    this._timer = setTimeout(() => this.fetch(q), this.delayValue);
  }

  onFocus() {
    if (this.inputTarget.value.trim().length >= this.minValue) return;
    // Show recent? For now, clear list
    this.renderList([]);
  }

  onKeydown(e) {
    const items = Array.from(this.listTarget.querySelectorAll('[data-index]'));
    if (!items.length) return;
    let idx = items.findIndex(li => li.classList.contains('bg-gray-100'));
    if (e.key === 'ArrowDown') { e.preventDefault(); idx = (idx + 1) % items.length; this.highlight(items, idx); }
    if (e.key === 'ArrowUp') { e.preventDefault(); idx = (idx - 1 + items.length) % items.length; this.highlight(items, idx); }
    if (e.key === 'Enter') { e.preventDefault(); if (idx >= 0) items[idx].click(); }
    if (e.key === 'Escape') { this.renderList([]); }
  }

  highlight(items, idx) {
    items.forEach((el, i) => el.classList.toggle('bg-gray-100', i === idx));
    items[idx]?.scrollIntoView({ block: 'nearest' });
  }

  async fetch(q) {
    const url = this.urlValue || "/patients/lookup?q=" + encodeURIComponent(q);
    const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
    if (!res.ok) return this.renderList([]);
    const data = await res.json();
    this.renderList(data);
  }

  renderList(items) {
    this.listTarget.innerHTML = '';
    if (!items || !items.length) { this.listTarget.classList.add('hidden'); return; }
    this.listTarget.classList.remove('hidden');
    items.forEach((row, i) => {
      const li = document.createElement('div');
      li.dataset.index = i;
      li.className = 'px-3 py-2 cursor-pointer hover:bg-gray-100';
      li.innerHTML = `<div class="font-medium">${row.label}</div>${row.subtitle ? `<div class="text-xs text-gray-500">${row.subtitle}</div>` : ''}`;
      li.addEventListener('click', () => this.pick(row));
      this.listTarget.appendChild(li);
    });
  }

  pick(row) {
    this.inputTarget.value = row.label;
    this.hiddenTarget.value = row.id;
    this.renderList([]);
    const form = this.element.closest('form');
    if (form && typeof form.requestSubmit === 'function') form.requestSubmit();
  }
}


