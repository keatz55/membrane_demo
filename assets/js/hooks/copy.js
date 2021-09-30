const Copy = {
  mounted() {
    this.el.onclick = () => {
      console.log(this.el.innerHTML);
      navigator.clipboard.writeText(this.el.innerHTML);
    };
  },
};

/** ************************************************************************* */

export default Copy;
