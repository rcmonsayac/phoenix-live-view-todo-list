export const SortableList = {
  mounted() {
    this.initList();
  },
  updated() {
    console.log("updated")
    this.initList();
  },
  dropped(){
    let beforePos, afterPos;
    beforePos = this.dragged.previousElementSibling ? parseFloat(this.dragged.previousElementSibling.dataset.sortOrder) : 0;
    afterPos = this.dragged.nextElementSibling ? parseFloat(this.dragged.nextElementSibling.dataset.sortOrder) : 0;
    this.pushEvent("sort", { 
      id: parseInt(this.dragged.dataset.sortableId) ,
      before_pos: beforePos,
      after_pos: afterPos
    });
  },
  sortList() {
    let draggedPos = Array.from(this.el.children).indexOf(this.dragged)
    let draggedOverPos = Array.from(this.el.children).indexOf(this.draggedOver)
    if(draggedPos != draggedOverPos) {
      if(draggedPos > draggedOverPos) {
        this.dragged.parentNode.insertBefore(this.dragged, this.draggedOver);
      } else {
        this.draggedOver.parentNode.insertBefore(this.dragged, this.draggedOver.nextSibling);
      }
    }
  },
  initList(){
    Array.from(this.el.children).forEach(element => {
      element.addEventListener("dragstart", (e) => {
        this.dragged = element;
        element.classList.add("dragged");
      });

      element.addEventListener("dragenter", (e) => {
        e.preventDefault();
        e.stopImmediatePropagation();
        this.draggedOver = element;
        this.sortList();
      });

      element.addEventListener("drop", (e) => {
        e.stopImmediatePropagation();
        this.dropped();
      });

      element.addEventListener("dragend", (e) => {
        element.classList.remove("dragged");
      });

    });
  }
}