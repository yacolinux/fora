/** @jsx React.DOM */
var React = require("react");

module.exports = React.createClass({
    render: function() {
        cover = this.props.cover;
        
        if (cover) {
            if (!cover.type)
               cover.type = "auto-cover";
                
            classString = ['cover', cover.type].join(' ');
            imageStyle = { "background-image": "url(" + cover.image.src + ")" };
            underlayStyle = {
                background: cover.bgColor, 
                opacity: cover.opacity, 
                color: cover.foreColor
            };
            
            if (cover.type !== "inline-cover") {
                return (
                    <div className={classString} data-field-type="cover" data-field-name={this.props.field} data-cover-format={cover.type} data-small-image={cover.image.small}>
                        <div className="image" style={imageStyle}>
                            <div className="underlay" style={underlayStyle}></div>
                            <div className="content-wrap" dangerouslySetInnerHTML={{__html: this.props.coverContent}}>
                            </div>
                        </div>
                    </div>
                );
            }
            else {
                return (
                    <div className={classString} data-field-type="cover" data-field-name={this.props.field} data-cover-format={cover.type} data-small-image={cover.image.small}>
                        <img src={cover.image.src} />
                    </div>
                );
            }      
        }
        else {
            return (<div></div>);
        }
    }
});



