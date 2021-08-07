
class Converter {

    constructor()
    {
        
    }

    static dividePropertiesBy10(obj)
    {
        let newObj = {};
//https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/entries
        for (const [key, value] of Object.entries(obj))
        {
            newObj[key] = value/10;
        }

        return newObj;
    }
}

export default Converter;