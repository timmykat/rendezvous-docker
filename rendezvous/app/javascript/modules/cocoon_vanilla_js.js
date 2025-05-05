let cocoon_element_counter = 0;

const create_new_id = () => new Date().getTime() + cocoon_element_counter++;

const newcontent_braced = id => '[' + id + ']$1';
const newcontent_underscord = id => '_' + id + '_$1';
const cocoon = document.querySelector('[data-coccon]')

const getInsertionNodeElem = (insertionNode, insertionTraversal, btn) => {
  if (!insertionNode) return btn.parentNode;

  if (typeof insertionNode === 'function') {
    if (insertionTraversal) {
      console.warn('association-insertion-traversal ignored when insertion-node is a function.');
    }
    return insertionNode(btn);
  }

  if (typeof insertionNode === 'string') {
    if (insertionTraversal) {
      const prevNext = {
        prev: 'previousElementSibling',
        next: 'nextElementSibling',
      }[insertionTraversal];

      if (prevNext) {
        const el = btn[prevNext]?.closest(insertionNode);
        return el === btn[prevNext] ? el : null;
      } else if (insertionTraversal === 'closest') {
        return btn.closest(insertionNode);
      } else {
        console.warn('Unsupported insertion traversal method:', insertionTraversal);
      }
    } else {
      return insertionNode === 'this' ? btn : cocoon?.querySelector(insertionNode);
    }
  }

  return null;
};

export const addFieldsHandler = (btn) => {
  const assoc = btn.dataset.association;
  const assocs = btn.dataset.associations;
  const content = btn.dataset.associationInsertionTemplate;
  const insertionNode = btn.dataset.associationInsertionNode;
  const insertionTraversal = btn.dataset.associationInsertionTraversal;
  let insertionMethod = btn.dataset.associationInsertionMethod || btn.dataset.associationInsertionPosition || 'before';

  let new_id = create_new_id();
  let count = parseInt(btn.dataset.count || 1, 10);
  let regexp_braced = new RegExp(`\\[new_${assoc}\\](.*?\\s)`, 'g');
  let regexp_underscord = new RegExp(`_new_${assoc}_(\\w*)`, 'g');
  let new_content = content.replace(regexp_braced, newcontent_braced(new_id));

  if (new_content === content && assocs) {
    regexp_braced = new RegExp(`\\[new_${assocs}\\](.*?\\s)`, 'g');
    regexp_underscord = new RegExp(`_new_${assocs}_(\\w*)`, 'g');
    new_content = content.replace(regexp_braced, newcontent_braced(new_id));
  }

  new_content = new_content.replace(regexp_underscord, newcontent_underscord(new_id));

  const insertionNodeElem = getInsertionNodeElem(insertionNode, insertionTraversal, btn);
  if (!insertionNodeElem) {
    console.warn("Couldn't find insertion node. Check data-association-insertion-* attributes.");
    return;
  }

  for (let i = 0; i < count; i++) {
    const id = create_new_id();
    let content_item = content.replace(regexp_braced, newcontent_braced(id));
    content_item = content_item.replace(regexp_underscord, newcontent_underscord(id));

    const event = new CustomEvent('cocoon:before-insert', { detail: content_item, bubbles: true, cancelable: true });
    insertionNodeElem.dispatchEvent(event);

    if (!event.defaultPrevented) {
      const methodMap = {
        before: 'beforebegin',
        after: 'afterend',
        append: 'beforeend',
        prepend: 'afterbegin'
      };
      insertionNodeElem.insertAdjacentHTML(methodMap[insertionMethod] || 'beforebegin', content_item);

      console.log('Triggering cocoon:after-insert')
      insertionNodeElem.dispatchEvent(
        new CustomEvent('cocoon:after-insert', { detail: content_item, bubbles: true, cancelable: true })
      );
    }
  }
};

export const removeFieldsHandler = (btn) => {
  const wrapperClass = btn.dataset.wrapperClass || 'nested-fields';
  const nodeToDelete = btn.closest(`.${wrapperClass}`);
  const triggerNode = nodeToDelete?.parentNode;

  const event = new CustomEvent('cocoon:before-remove', { detail: nodeToDelete, bubbles: true, cancelable: true });
  triggerNode?.dispatchEvent(event);

  if (!event.defaultPrevented) {
    const timeout = parseInt(triggerNode?.dataset.removeTimeout || 0, 10);

    setTimeout(() => {
      if (btn.classList.contains('dynamic')) {
        nodeToDelete?.remove();
      } else {
        const input = nodeToDelete?.querySelector('input[type=hidden][name*="[_destroy]"]');
        if (input) input.value = 1;
        if (nodeToDelete) nodeToDelete.style.display = 'none';
      }

      console.log('Triggering cocoon:after-remove')
      triggerNode?.dispatchEvent(
        new CustomEvent('cocoon:after-remove', { detail: nodeToDelete, bubbles: true, cancelable: true })
      );
    }, timeout);
  }
};

export const hideDestroyedFields = () => {
  cocoon?.querySelectorAll('.remove_fields.existing.destroyed').forEach((btn) => {
    const wrapperClass = btn.dataset.wrapperClass || 'nested-fields';
    const field = btn.closest(`.${wrapperClass}`);
    if (field) field.style.display = 'none';
  });
};

export const registerCocoonHandlers = () => {
  console.log('Registering cocoon handlers')
  cocoon?.addEventListener('click', (e) => {
    const addBtn = e.target.closest('.add_fields');
    if (addBtn) {
      console.log('Clicked add fields')
      e.preventDefault();
      e.stopPropagation();
      addFieldsHandler(addBtn);
    }

    const removeBtn =
      e.target.closest('.remove_fields.dynamic') ||
      e.target.closest('.remove_fields.existing');

    if (removeBtn) {
      console.log('Clicked remove fields')
      e.preventDefault();
      e.stopPropagation();
      removeFieldsHandler(removeBtn);
    }
  });

  document.addEventListener('DOMContentLoaded', hideDestroyedFields);
  document.addEventListener('turbolinks:load', hideDestroyedFields);
  document.addEventListener('turbo:load', hideDestroyedFields);
};
